const std = @import("std");

pub const ProperDivisorSums = struct {
    divisor_sums: []u32,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, limit: usize) ProperDivisorSums {
        const smallest_prime_factors = allocator.alloc(u32, limit + 1) catch unreachable;
        defer allocator.free(smallest_prime_factors);

        for (smallest_prime_factors, 0..) |*v, idx| v.* = @intCast(idx);

        var i: usize = 2;
        while (i * i <= limit) : (i += 1) {
            if (smallest_prime_factors[i] == i) {
                var j: usize = i * i;
                while (j <= limit) : (j += i) {
                    if (smallest_prime_factors[j] == j) {
                        smallest_prime_factors[j] = @intCast(i);
                    }
                }
            }
        }

        const sigma = allocator.alloc(u32, limit + 1) catch unreachable;
        defer allocator.free(sigma);

        if (limit >= 1) sigma[1] = 1;

        var n: usize = 2;
        while (n <= limit) : (n += 1) {
            const p: usize = smallest_prime_factors[n];
            const m: usize = n / p;
            if (smallest_prime_factors[m] != p) {
                sigma[n] = (1 + @as(u32, @intCast(p))) * sigma[m];
            } else {
                sigma[n] = sigma[m] * (1 + @as(u32, @intCast(p))) - sigma[m / p] * @as(u32, @intCast(p));
            }
        }

        const divisor_sums = allocator.alloc(u32, limit + 1) catch unreachable;
        for (divisor_sums, sigma, 0..) |*ds, s, idx| {
            ds.* = if (s >= idx) s - @as(u32, @intCast(idx)) else 0;
        }

        return ProperDivisorSums{
            .divisor_sums = divisor_sums,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *ProperDivisorSums) void {
        self.allocator.free(self.divisor_sums);
    }

    pub fn get(self: *const ProperDivisorSums, n: u32) u32 {
        return self.divisor_sums[n];
    }
};