const std = @import("std");

const LIMIT = 4_000_000;

pub fn solve_0002(_: std.mem.Allocator, _: std.mem.Allocator) u32 {
    var f_n: u32 = 2;
    var f_n3: u32 = 8;
    var sum: u32 = 2;

    while (f_n3 <= LIMIT) {
        sum += f_n3;
        const f_n_prev = f_n;
        f_n = f_n3;
        f_n3 = 4 * f_n3 + f_n_prev;
    }

    return sum;
}
