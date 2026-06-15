const std = @import("std");
const SegmentedSieve = @import("primeZ").sieve.SegmentedSieve;
const nthPrimeUpperBound = @import("primeZ").estimates.nthPrimeUpperBound;

const N_TH: usize = 10001;

pub fn solve_0007(gpa: std.mem.Allocator, _: std.mem.Allocator) usize {
    const allocator = gpa;
    const upperBound = nthPrimeUpperBound(N_TH);
    var sieve = SegmentedSieve.init(allocator, upperBound) catch unreachable;
    defer sieve.deinit();
    const primes = sieve.getPrimes(allocator) catch unreachable;
    defer allocator.free(primes);

    return primes[N_TH-1];
}
