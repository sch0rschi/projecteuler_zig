const std = @import("std");
const primeZ = @import("primeZ");

const LIMIT: usize = 20;

pub fn solve_0005(gpa: std.mem.Allocator, _: std.mem.Allocator) u32 {
    var sieve = primeZ.sieve.SegmentedSieve.init(gpa, LIMIT) catch unreachable;
    defer sieve.deinit();

    var result: u32 = 1;

    for (sieve.primes) |p| {
        var power: usize = p;

        // Find largest power of p <= LIMIT
        while (power * p <= LIMIT) {
            power *= p;
        }

        result *= @as(u32, @intCast(power));
    }

    return result;
}
