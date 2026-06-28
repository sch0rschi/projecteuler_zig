const std = @import("std");
const Primes = @import("primeZ").Primes;

const LIMIT: usize = 2_000_000;

pub fn solve_0010(gpa: std.mem.Allocator, _: std.mem.Allocator) u64 {
    const allocator = gpa;
    return Primes.sumPrimes(allocator, LIMIT) catch unreachable;
}
