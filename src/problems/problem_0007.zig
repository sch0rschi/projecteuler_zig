const std = @import("std");
const IteratingSieve = @import("primeZ").IteratingSieve;

const N_TH: usize = 10001;

pub fn solve_0007(gpa: std.mem.Allocator, _: std.mem.Allocator) usize {
    const allocator = gpa;
    return IteratingSieve.nthPrime(allocator, N_TH-1) catch unreachable;
}
