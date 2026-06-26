const std = @import("std");
const IteratingSieve = @import("primeZ").IteratingSieve;

const LIMIT: usize = 2_000_000;

pub fn solve_0010(gpa: std.mem.Allocator, _: std.mem.Allocator) u64 {
    const allocator = gpa;
    return IteratingSieve.sumPrimesLimit(allocator, LIMIT) catch unreachable;
}
