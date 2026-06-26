const std = @import("std");
const ProperDivisorSums = @import("libs").ProperDivisorSums;

const LIMIT: usize = 1_000_000;

const State = enum { unvisited, visiting, processed };

pub fn solve_0095(allocator: std.mem.Allocator, _: std.mem.Allocator) u32 {
    var proper_divisor_sums = ProperDivisorSums.init(allocator, LIMIT);
    defer proper_divisor_sums.deinit();

    // unvisited = not yet seen
    // visiting  = currently on the path being walked
    // processed = path fully resolved (cycle found and recorded, or dead end)
    const state = allocator.alloc(State, LIMIT + 1) catch unreachable;
    defer allocator.free(state);
    for (state) |*s| s.* = .unvisited;

    var best_len: usize = 0;
    var best_min: u32 = 0;

    var path = std.ArrayList(u32).initCapacity(allocator, 1024) catch unreachable;
    defer path.deinit(allocator);

    var start: usize = 1;
    while (start <= LIMIT) : (start += 1) {
        if (state[start] != .unvisited) continue;

        var cur: u32 = @intCast(start);
        path.clearRetainingCapacity();

        while (cur <= LIMIT) {
            switch (state[cur]) {
                .unvisited => {
                    state[cur] = .visiting;
                    path.append(allocator, cur) catch unreachable;
                    cur = proper_divisor_sums.get(cur);
                },
                .visiting => {
                    const cycle_start = cur;

                    var idx = path.items.len;
                    while (idx > 0) {
                        idx -= 1;
                        if (path.items[idx] == cycle_start) break;
                    }

                    const cycle = path.items[idx..];

                    const len = cycle.len;
                    var min_val = cycle[0];
                    for (cycle[1..]) |v| {
                        if (v < min_val) min_val = v;
                    }

                    if (len > best_len) {
                        best_len = len;
                        best_min = min_val;
                    }

                    for (cycle) |v| state[v] = .processed;

                    break;
                },
                .processed => break,
            }
        }

        for (path.items) |v| state[v] = .processed;
    }

    return best_min;
}
