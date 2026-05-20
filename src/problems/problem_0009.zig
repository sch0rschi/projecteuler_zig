const std = @import("std");
const Triplet = @import("libs").Triplet;
const expand = @import("libs").expand;
const R = @import("libs").R;

fn expansion_recursion(t: Triplet) ?Triplet {
    const s = t.sum();

    if (1000 % s == 0) return t;
    if (s > 1000) return null;

    const e = expand(t);

    if (expansion_recursion(e[2])) |res| return res;
    if (expansion_recursion(e[1])) |res| return res;
    if (expansion_recursion(e[0])) |res| return res;

    return null;
}

pub fn solve_0009(_: std.mem.Allocator, _: std.mem.Allocator) usize {
    const result = expansion_recursion(R) orelse unreachable;

    const scaling = 1000 / result.sum();

    return result.product() * scaling * scaling * scaling;
}
