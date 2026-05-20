const std = @import("std");

pub fn solve_0004(_: std.mem.Allocator, _: std.mem.Allocator) u32 {

    var n: u32 = 999;
    while (n >= 100) : (n -= 1) {
        const p = makePalindrome(n);
        if (isValidProduct(p)) return p;
    }

    unreachable;
}

fn makePalindrome(n0: u32) u32 {
    var n = n0;
    var acc = n0;

    while (n > 0) {
        acc = acc * 10 + (n % 10);
        n /= 10;
    }

    return acc;
}

fn isValidProduct(p: u32) bool {
    const sqrt_p = std.math.sqrt(p);
    const lower = @max(p / 999, sqrt_p);
    const upper = @min(p / 100, 999);

    var d: u32 = lower;
    while (d <= upper) : (d += 1) {
        if (p % d == 0) return true;
    }

    return false;
}
