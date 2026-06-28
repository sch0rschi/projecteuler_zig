const std = @import("std");
const PrimeCheck = @import("primeZ").PrimeCheck;

pub fn solve_0058(_: std.mem.Allocator, _: std.mem.Allocator) u32 {
    var result: u32 = 0;

    var diagonal_prime_count: usize = 0;
    var diagonal_elements_count: usize = 1;

    var top_right: usize = 1;
    var top_left: usize = 1;
    var bottom_left: usize = 1;

    var adding: usize = 0;

    var i: usize = 3;
    while (true) : (i += 2) {
        top_right += 2 + adding;
        top_left += 4 + adding;
        bottom_left += 6 + adding;
        adding += 8;

        diagonal_elements_count += 4;

        diagonal_prime_count +=
        (@as(usize, @intFromBool(PrimeCheck.isPrime(top_left))) +
        @as(usize, @intFromBool(PrimeCheck.isPrime(top_right))) +
        @as(usize, @intFromBool(PrimeCheck.isPrime(bottom_left))));

        if (10 * diagonal_prime_count < diagonal_elements_count) {
            result = @intCast(i);
            break;
        }
    }

    return result;
}
