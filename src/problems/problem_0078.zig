const std = @import("std");

const MODULO: i32 = 1_000_000;
const LIMIT: usize = 60_000;

const Pent = struct { g1: usize, g2: usize };

// https://en.wikipedia.org/wiki/Partition_function_(number_theory)#Recurrence_relations
pub fn solve_0078(allocator: std.mem.Allocator, _: std.mem.Allocator) usize {
    const table = allocator.alloc(i32, LIMIT + 1) catch unreachable;
    defer allocator.free(table);
    @memset(table, 0);
    table[0] = 1;

    var pents = std.ArrayList(Pent).initCapacity(allocator, 0) catch unreachable;
    defer pents.deinit(allocator);

    var k: usize = 1;
    while (true) {
        const g1 = k * (3 * k - 1) / 2;
        if (g1 > LIMIT) break;
        const g2 = k * (3 * k + 1) / 2;
        pents.append(allocator, .{ .g1 = g1, .g2 = g2 }) catch unreachable;
        k += 1;
    }

    var n: usize = 1;
    while (n <= LIMIT) : (n += 1) {
        var val: i32 = 0;

        for (pents.items, 0..) |p, i| {
            if (p.g1 > n) break;
            const sign: i32 = if (i % 2 == 0) 1 else -1;
            val += sign * table[n - p.g1];
            if (p.g2 <= n) {
                val += sign * table[n - p.g2];
            }
        }

        table[n] = @mod(val, MODULO);

        if (table[n] == 0) {
            return n;
        }
    }

    @panic("A solution should have been found.");
}
