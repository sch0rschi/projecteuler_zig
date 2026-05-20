const std = @import("std");
const solutions = @import("solutions");

const WARMUP: u32 = 100;
const ITERATIONS: u32 = 100;

const Result = struct {
    name: []const u8,
    min_ns: u96,
    avg_ns: u96,
    max_ns: u96,
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buf = std.Io.File.stdout().writer(io, &.{});
    const stdout = &stdout_buf.interface;
    var stderr_buf = std.Io.File.stderr().writer(io, &.{});
    const stderr = &stderr_buf.interface;

    const all = solutions.SOLUTIONS;
    const total_tasks = all.len;

    // ── Warmup ────────────────────────────────────────────────────────────────
    try stderr.print("Warmup starting...\n", .{});
    for (all, 0..) |p, i| {
        var r: u32 = 0;
        while (r < WARMUP) : (r += 1) {
            _ = try p.solve(init);
            try printProgress(stderr, "Warmup", i * WARMUP + r + 1, total_tasks * WARMUP);
        }
    }
    try clearLine(stderr);
    try stderr.print("Warmup complete.\n", .{});

    // ── Benchmark ─────────────────────────────────────────────────────────────
    try stderr.print("\nBenchmark starting...\n", .{});
    try printTableHeader(stdout);

    var results = std.ArrayList(Result).initCapacity(init.gpa, 0) catch unreachable;
    defer results.deinit(init.gpa);

    for (all, 0..) |p, i| {
        var total_ns: u96 = 0;
        var min_ns: u96 = std.math.maxInt(u96);
        var max_ns: u96 = 0;

        var r: u32 = 0;
        while (r < ITERATIONS) : (r += 1) {
            const start = std.Io.Clock.now(.awake, io);
            _ = try p.solve(init);
            const elapsed = @as(u96, @intCast(start.untilNow(io, .awake).nanoseconds));
            total_ns += elapsed;
            if (elapsed < min_ns) min_ns = elapsed;
            if (elapsed > max_ns) max_ns = elapsed;
            try printProgress(stderr, "Benchmark", i * ITERATIONS + r + 1, total_tasks * ITERATIONS);
        }

        try clearLine(stderr);

        const res = Result{
            .name = p.name,
            .min_ns = min_ns,
            .avg_ns = @divTrunc(total_ns, ITERATIONS),
            .max_ns = max_ns,
        };
        try printResultLine(stdout, res);
        try results.append(init.gpa, res);
    }

    try clearLine(stderr);
    try stderr.print("Benchmark complete.\n", .{});

    // ── Split stats ───────────────────────────────────────────────────────────
    const mid = results.items.len / 2;
    var first_ns: u96 = 0;
    var second_ns: u96 = 0;
    for (results.items[0..mid]) |r| first_ns += r.avg_ns;
    for (results.items[mid..]) |r| second_ns += r.avg_ns;
    const total_ns = first_ns + second_ns;

    try stdout.print("Total  : {s}\n", .{formatDuration(total_ns)});

    // ── Top 10 slowest (all) ──────────────────────────────────────────────────
    try stdout.print("\nTop 10 slowest (all):\n", .{});
    var all_sorted = try std.ArrayList(Result).initCapacity(init.gpa, results.items.len);
    try all_sorted.appendSlice(init.gpa, results.items);
    std.mem.sort(Result, all_sorted.items, {}, resultSlowerFirst);
    try printTableHeader(stdout);
    for (all_sorted.items[0..@min(10, all_sorted.items.len)]) |r|
        try printResultLine(stdout, r);
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

fn resultSlowerFirst(_: void, a: Result, b: Result) bool {
    return a.avg_ns > b.avg_ns;
}

fn printTableHeader(w: anytype) !void {
    try w.print("{s:<8} {s:>12} {s:>12} {s:>12}\n", .{ "Prob", "Min", "Avg", "Max" });
    try w.print("{s}\n", .{"-" ** 48});
}

fn printResultLine(w: anytype, r: Result) !void {
    try w.print("{s:<8} {s:>12} {s:>12} {s:>12}\n", .{
        r.name,
        formatDuration(r.min_ns),
        formatDuration(r.avg_ns),
        formatDuration(r.max_ns),
    });
}

fn printProgress(w: anytype, label: []const u8, current: usize, total: usize) !void {
    const progress = @as(f32, @floatFromInt(current)) / @as(f32, @floatFromInt(total));
    const percent = progress * 100.0;
    const width = 30;
    const filled: usize = @intFromFloat(progress * @as(f32, @floatFromInt(width)));
    const empty = width - filled;
    try w.print("\r{s} [", .{label});
    for (0..filled) |_| try w.writeByte('#');
    for (0..empty) |_| try w.writeByte('.');
    try w.print("] {d:5.1}%", .{percent});
}

fn clearLine(w: anytype) !void {
    try w.print("\r\x1b[2K", .{});
}

fn formatDuration(ns: u96) []const u8 {
    const S = struct {
        var bufs: [3][20]u8 = undefined;
        var idx: usize = 0;
    };
    const buf = &S.bufs[S.idx % 3];
    S.idx += 1;
    const result = if (ns < 1_000)
        std.fmt.bufPrint(buf, "{d:>10} ns", .{ns})
    else if (ns < 1_000_000)
            std.fmt.bufPrint(buf, "{d:>10.3} µs", .{@as(f64, @floatFromInt(ns)) / 1_000.0})
        else if (ns < 1_000_000_000)
                std.fmt.bufPrint(buf, "{d:>10.3} ms", .{@as(f64, @floatFromInt(ns)) / 1_000_000.0})
            else
                std.fmt.bufPrint(buf, "{d:>10.3}  s", .{@as(f64, @floatFromInt(ns)) / 1_000_000_000.0});
    return result catch buf;
}