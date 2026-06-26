const std = @import("std");

const LIMIT: usize = 1_000_000;

const ChainResult = struct { next: usize, count: u32 };

// https://risingentropy.com/2019/06/12/record-breaking-collatz-chains/
pub fn solve_0014(allocator: std.mem.Allocator, _: std.mem.Allocator) usize {
    const chain_lengths = allocator.alloc(u32, LIMIT) catch unreachable;
    defer allocator.free(chain_lengths);
    @memset(chain_lengths, 0);

    chain_lengths[2] = 1;
    chain_lengths[3] = 7;
    chain_lengths[4] = 2;
    chain_lengths[5] = 5;
    chain_lengths[6] = 8;
    chain_lengths[7] = 16;
    chain_lengths[8] = 3;
    chain_lengths[9] = 19;
    chain_lengths[10] = 6;
    chain_lengths[11] = 14;

    var base: usize = 12;
    while (base < LIMIT - 12) : (base += 12) {
        // n mod 12 == 0
        chain_lengths[base] = chain_lengths[base / 2] + 1;
        // n mod 12 == 2
        const chain_length_2 = chain_lengths[(base + 2) / 2] + 1;
        chain_lengths[base + 2] = chain_length_2;
        // n mod 12 == 4
        chain_lengths[base + 4] = chain_lengths[(base + 4) / 2] + 1;
        // n mod 12 == 6
        chain_lengths[base + 6] = chain_lengths[(base + 6) / 2] + 1;
        // n mod 12 == 8
        const chain_length_8 = chain_lengths[(base + 8) / 2] + 1;
        chain_lengths[base + 8] = chain_length_8;
        // n mod 12 == 10
        chain_lengths[base + 10] = chain_lengths[(base + 10) / 2] + 1;

        // n mod 12 == 1
        {
            const n = base + 1;
            const target = (3 * n + 1) / 4;
            chain_lengths[n] = chain_lengths[target] + 3;
        }
        // n mod 12 == 5
        {
            const n = base + 5;
            const target = (3 * n + 1) / 4;
            chain_lengths[n] = chain_lengths[target] + 3;
        }

        // n mod 12 == 3
        chain_lengths[base + 3] = chain_length_2;
        // n mod 12 == 9
        chain_lengths[base + 9] = chain_length_8;

        // n mod 12 == 7
        {
            const n = base + 7;
            const result = buildChain(n);
            chain_lengths[n] = result.count + chain_lengths[result.next];
        }
        // n mod 12 == 11
        {
            const n = base + 11;
            const result = buildChain(n);
            chain_lengths[n] = result.count + chain_lengths[result.next];
        }
    }

    base = 12 * (LIMIT / 12);
    chain_lengths[base] = chain_lengths[base / 2] + 1;
    {
        const n = base + 1;
        const target = (3 * n + 1) / 4;
        chain_lengths[n] = chain_lengths[target] + 3;
    }
    chain_lengths[base + 2] = chain_lengths[(base + 2) / 2] + 1;
    chain_lengths[base + 3] = chain_lengths[base + 2];

    var best_idx: usize = 0;
    var best_len: u32 = 0;
    for (chain_lengths, 0..) |len, idx| {
        if (len > best_len) {
            best_len = len;
            best_idx = idx;
        }
    }

    return best_idx;
}

inline fn buildChain(n: usize) ChainResult {
    var next = n;
    var count: u32 = 0;
    while (true) {
        next = nextCollatz(next);
        count += 1;
        if (next < n) {
            return .{ .next = next, .count = count };
        }
    }
}

inline fn nextCollatz(n: usize) usize {
    return if (n % 2 == 0) n / 2 else 3 * n + 1;
}
