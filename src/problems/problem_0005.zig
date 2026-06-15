const std = @import("std");
const primeZ = @import("primeZ");

const LIMIT: usize = 20;

pub fn solve_0005(gpa: std.mem.Allocator, _: std.mem.Allocator) u32 {
    const allocator = gpa;
    var sieve = primeZ.sieve.SegmentedSieve.init(allocator, LIMIT) catch unreachable;
    defer sieve.deinit();
    const primes = sieve.getPrimes(allocator) catch unreachable;
    defer allocator.free(primes);

    var result: u32 = 1;

    for (primes) |p| {
        var power: usize = p;

        // Find largest power of p <= LIMIT
        while (power * p <= LIMIT) {
            power *= p;
        }

        result *= @as(u32, @intCast(power));
    }

    return result;
}
