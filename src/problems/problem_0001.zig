const std = @import("std");

const LIMIT = 999;

pub fn solve_0001(_: std.mem.Allocator, _: std.mem.Allocator) u32 {
    return scaled_triangular(3) + scaled_triangular(5) - scaled_triangular(15);
}

fn scaled_triangular(n: u32) u32 {
    const m = LIMIT / n;
    return n * m * (m+1) / 2;
}
