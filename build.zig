const std = @import("std");

pub fn build(b: *std.Build) void {
    generateSolutionsFile(b) catch @panic("failed generating solutions");

    const lib_mod = b.addModule("libs", .{
        .root_source_file = b.path("src/libs/libs.zig"),
    });

    const primez = b.dependency("primeZ", .{});
    const primez_mod = primez.module("primeZ");

    const solutions_mod = b.addModule("solutions", .{
        .root_source_file = b.path("src/problems/solutions.zig"),
        .imports = &.{ .{ .name = "libs", .module = lib_mod }, .{ .name = "primeZ", .module = primez_mod } },
    });

    addTests(b, lib_mod, solutions_mod, primez_mod);
    addBenches(b, lib_mod, solutions_mod, primez_mod);
}

fn addTests(b: *std.Build, lib_mod: *std.Build.Module, solutions_mod: *std.Build.Module, primez_mod: *std.Build.Module) void {
    const test_step = b.step("test", "Run all tests");
    const install_test_step = b.step("install_tests", "Install test binaries to zig-out/tests/");

    const all_tests = [_]struct { name: []const u8, path: []const u8 }{
        .{ .name = "test_solutions", .path = "src/tests/solutions_test.zig" },
    };

    inline for (all_tests) |s| {
        const t = b.addTest(.{
            .name = s.name,
            .root_module = b.createModule(.{
                .root_source_file = b.path(s.path),
                .target = b.graph.host,
                .optimize = .Debug,
                .imports = &.{
                    .{ .name = "libs", .module = lib_mod },
                    .{ .name = "solutions", .module = solutions_mod },
                    .{ .name = "primeZ", .module = primez_mod },
                },
            }),
        });

        b.installArtifact(t);
        install_test_step.dependOn(&b.addInstallArtifact(t, .{
            .dest_dir = .{ .override = .{ .custom = "tests" } },
        }).step);
        test_step.dependOn(&b.addRunArtifact(t).step);
    }
}

fn addBenches(b: *std.Build, lib_mod: *std.Build.Module, solutions_mod: *std.Build.Module, primez_mod: *std.Build.Module) void {
    const bench_step = b.step("bench", "Run all benchmarks");

    const all_benches = [_]struct { name: []const u8, path: []const u8 }{
        .{ .name = "bench_solutions", .path = "src/benches/solutions_bench.zig" },
    };

    inline for (all_benches) |s| {
        const exe = b.addExecutable(.{
            .name = s.name,
            .root_module = b.createModule(.{
                .root_source_file = b.path(s.path),
                .target = b.graph.host,
                .optimize = .ReleaseFast,
                .imports = &.{
                    .{ .name = "libs", .module = lib_mod },
                    .{ .name = "solutions", .module = solutions_mod },
                    .{ .name = "primeZ", .module = primez_mod },
                },
            }),
        });
        b.installArtifact(exe);

        const run = b.addRunArtifact(exe);
        b.step("bench_" ++ s.name["bench_".len..], "Run the " ++ s.name ++ " benchmark")
            .dependOn(&run.step);
        bench_step.dependOn(&run.step);
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// SOLUTIONS GENERATOR
// ─────────────────────────────────────────────────────────────────────────────

fn generateSolutionsFile(b: *std.Build) !void {
    const allocator = b.allocator;
    const io = b.graph.io;

    var dir = try b.build_root.handle.openDir(
        io,
        "src/problems",
        .{ .iterate = true },
    );
    defer dir.close(io);

    var entries: std.ArrayList([]const u8) = .empty;
    defer {
        for (entries.items) |e| allocator.free(e);
        entries.deinit(allocator);
    }

    var it = dir.iterate();
    while (try it.next(io)) |entry| {
        if (entry.kind != .file) continue;
        if (!std.mem.startsWith(u8, entry.name, "problem_")) continue;
        if (!std.mem.endsWith(u8, entry.name, ".zig")) continue;
        const number = entry.name["problem_".len .. entry.name.len - ".zig".len];
        try entries.append(allocator, try allocator.dupe(u8, number));
    }

    std.mem.sort([]const u8, entries.items, {}, struct {
        fn lessThan(_: void, e1: []const u8, e2: []const u8) bool {
            return std.mem.lessThan(u8, e1, e2);
        }
    }.lessThan);

    var out: std.ArrayList(u8) = .empty;
    defer out.deinit(allocator);

    try out.appendSlice(allocator,
        \\// AUTO-GENERATED FILE — do not edit by hand
        \\
        \\const std = @import("std");
        \\
        \\/// Tagged union that covers every return type a problem's solve function
        \\/// may produce.  Wrappers in SOLUTIONS coerce to this automatically so
        \\/// that callers (bench, runners, …) never need to know the concrete type.
        \\pub const Answer = union(enum) {
        \\    uint: u64,
        \\    int:  i64,
        \\    str:  []const u8,
        \\
        \\    pub fn format(
        \\        self: Answer,
        \\        comptime _: []const u8,
        \\        _: std.fmt.FormatOptions,
        \\        writer: anytype,
        \\    ) !void {
        \\        switch (self) {
        \\            .uint => |v| try writer.print("{d}", .{v}),
        \\            .int  => |v| try writer.print("{d}", .{v}),
        \\            .str  => |v| try writer.writeAll(v),
        \\        }
        \\    }
        \\};
        \\
        \\pub const Solution = struct {
        \\    name:  []const u8,
        \\    solve: *const fn (std.process.Init) anyerror!Answer,
        \\};
        \\
        \\
    );

    for (entries.items) |num| {
        const line = try std.fmt.allocPrint(
            allocator,
            "pub const problem_{s} = @import(\"problem_{s}.zig\");\n",
            .{ num, num },
        );
        defer allocator.free(line);
        try out.appendSlice(allocator, line);
    }

    try out.appendSlice(allocator, "\npub const SOLUTIONS: []const Solution = &.{\n");
    for (entries.items) |num| {
        const line = try std.fmt.allocPrint(allocator,
            \\    .{{ .name = "{s}", .solve = &struct {{
            \\        fn solve(init: std.process.Init) anyerror!Answer {{
            \\            const raw = problem_{s}.solve_{s}(init.gpa, init.gpa);
            \\            return switch (@typeInfo(@TypeOf(raw))) {{
            \\                .int => |i| if (i.signedness == .unsigned)
            \\                    Answer{{ .uint = @intCast(raw) }}
            \\                else
            \\                    Answer{{ .int  = @intCast(raw) }},
            \\                .pointer => Answer{{ .str = raw }},
            \\                else => @compileError("unsupported answer type: " ++ @typeName(@TypeOf(raw))),
            \\            }};
            \\        }}
            \\    }}.solve }},
            \\
        , .{ num, num, num });
        defer allocator.free(line);
        try out.appendSlice(allocator, line);
    }
    try out.appendSlice(allocator, "};\n");

    const file = try b.build_root.handle.createFile(io, "src/problems/solutions.zig", .{});
    defer file.close(io);
    try file.writeStreamingAll(io, out.items);
}
