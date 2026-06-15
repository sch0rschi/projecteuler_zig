const std = @import("std");
const SegmentedSieve = @import("primeZ").sieve.SegmentedSieve;

const LIMIT: usize = 2_000_000;

pub fn solve_0010(gpa: std.mem.Allocator, _: std.mem.Allocator) u64 {
    const allocator = gpa;
    var sieve = SegmentedSieve.init(gpa, LIMIT) catch unreachable;
    defer sieve.deinit();
    const primes = sieve.getPrimes(allocator) catch unreachable;
    defer allocator.free(primes);

    var sum: usize = 0;

    for (primes) |p| {
        sum += p;
    }

    return sum;
}
