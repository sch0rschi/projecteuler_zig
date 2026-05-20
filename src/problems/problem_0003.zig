const std = @import("std");

pub fn solve_0003(_: std.mem.Allocator, _: std.mem.Allocator) u64 {
    return largest_prime_factor(600_851_475_143);
}

fn largest_prime_factor(n: u64) u64 {
    var remaining = n;
    var factor: u64 = 3;

    while (factor * factor <= remaining) {
        if (remaining % factor == 0) {
            while (remaining % factor == 0) {
                remaining /= factor;
            }
        } else {
            factor += 2;
        }
    }

    return remaining;
}