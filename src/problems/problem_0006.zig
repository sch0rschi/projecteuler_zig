const std = @import("std");

const LIMIT: u32 = 100;

pub fn solve_0006(_: std.mem.Allocator, _: std.mem.Allocator) u32 {
    const sum = LIMIT * (LIMIT + 1) / 2;
    const sum_sq = LIMIT * (LIMIT + 1) * (2 * LIMIT + 1) / 6;

    return sum * sum - sum_sq;
}
