const std = @import("std");

const PrimeStore = @import("primeZ").PrimeStore;

// This constant is an "educated" guess
const MAX_PRIME_SEARCH: usize = 10_000;

const Frame = struct {
    depth: usize,
    sum: usize,
    gathered_node_indices: [5]usize,
};

pub fn solve_0060(allocator: std.mem.Allocator, _: std.mem.Allocator) usize {
    var primeStore = PrimeStore.initForQueriesAndPrimes(allocator, MAX_PRIME_SEARCH * MAX_PRIME_SEARCH, MAX_PRIME_SEARCH) catch unreachable;
    defer primeStore.deinit();

    var best: usize = std.math.maxInt(usize);

    prepareThenSearch(allocator, &primeStore, &best, 1);
    prepareThenSearch(allocator, &primeStore, &best, 2);

    return best;
}

fn prepareThenSearch(allocator: std.mem.Allocator, primeStore: *const PrimeStore, best: *usize, congruent: usize) void {
    var compatiblePrimes = std.ArrayList(usize).initCapacity(allocator, (primeStore.getPrimes() catch unreachable).len) catch unreachable;
    defer compatiblePrimes.deinit(allocator);

    for (primeStore.getPrimes() catch unreachable) |p| {
        if (p > MAX_PRIME_SEARCH) break;
        if (p == 3 or p % 3 == congruent) {
            compatiblePrimes.append(allocator, p) catch unreachable;
        }
    }

    const n = compatiblePrimes.items.len;
    const map_len = n * (n - 1) / 2;
    var both_concat_prime_map = allocator.alloc(bool, map_len) catch unreachable;
    defer allocator.free(both_concat_prime_map);
    @memset(both_concat_prime_map, false);

    var factors = allocator.alloc(usize, n) catch unreachable;
    defer allocator.free(factors);

    var threshold: usize = 10;
    for (compatiblePrimes.items, 0..) |p, idx| {
        while (threshold <= p) {
            threshold *= 10;
        }
        factors[idx] = threshold;
    }

    for (compatiblePrimes.items, 0..) |p2, index2| {
        const factor_p2 = factors[index2];
        for (compatiblePrimes.items[0..index2], 0..) |p1, index1| {
            both_concat_prime_map[triangularIndex(index1, index2)] =
            bothConcatPrime(p1, p2, factors[index1], factor_p2, primeStore);
        }
    }

    search(allocator, compatiblePrimes.items, both_concat_prime_map, best);
}

inline fn search(allocator: std.mem.Allocator, primes: []const usize, both_concat_prime_map: []const bool, best: *usize) void {
    var stack = std.ArrayList(Frame).initCapacity(allocator, 0) catch unreachable;
    defer stack.deinit(allocator);

    if (primes.len > 4) {
        var i: usize = primes.len - 1 - 4;
        while (true) {
            const p = primes[i];
            stack.append(allocator, Frame{
                .depth = 1,
                .sum = p,
                .gathered_node_indices = [_]usize{i} ** 5,
            }) catch unreachable;
            if (i == 0) break;
            i -= 1;
        }
    }

    while (stack.items.len > 0) {
        const frame = stack.pop().?;
        const current_depth = frame.depth;
        const current_sum = frame.sum;
        const gathered_node_indices = frame.gathered_node_indices;

        if (current_depth == 5) {
            best.* = @min(current_sum, best.*);
            continue;
        }

        const remaining = 5 - current_depth;
        const start = gathered_node_indices[current_depth - 1] + 1;
        const end = primes.len - 4 + current_depth;

        if (start >= end) continue;

        var potential_index: usize = end - 1;
        while (true) {
            const potential_prime = primes[potential_index];

            if (current_sum + remaining * potential_prime >= best.*) {
                break;
            }

            var all_both_concatenate_prime = true;
            for (gathered_node_indices[0..current_depth]) |gathered_node_index| {
                if (!both_concat_prime_map[triangularIndex(gathered_node_index, potential_index)]) {
                    all_both_concatenate_prime = false;
                    break;
                }
            }

            if (all_both_concatenate_prime) {
                var new_frame = frame;
                new_frame.depth = current_depth + 1;
                new_frame.sum = current_sum + potential_prime;
                new_frame.gathered_node_indices[current_depth] = potential_index;

                stack.append(allocator, new_frame) catch unreachable;
            }

            if (potential_index == start) break;
            potential_index -= 1;
        }
    }
}

fn triangularIndex(i: usize, j: usize) usize {
    return j * (j - 1) / 2 + i;
}

fn bothConcatPrime(a: usize, b: usize, factor_a: usize, factor_b: usize, primeStore: *const PrimeStore) bool {
    return primeStore.isPrime(a * factor_b + b) and primeStore.isPrime(b * factor_a + a);
}