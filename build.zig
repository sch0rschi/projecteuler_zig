const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    generateSolutionsFile(b) catch @panic("failed generating solutions");

    const lib_mod = b.addModule("libs", .{
        .root_source_file = b.path("src/libs/libs.zig"),
    });

    const primez = b.dependency("primeZ", .{
        .target = target,
    });
    const primez_mod = primez.module("primeZ");

    const solutions_mod = b.addModule("solutions", .{
        .root_source_file = b.path("src/problems/solutions.zig"),
        .imports = &.{ .{ .name = "libs", .module = lib_mod }, .{ .name = "primeZ", .module = primez_mod } },
    });

    const imports = &[_]std.Build.Module.Import{
        .{ .name = "libs", .module = lib_mod },
        .{ .name = "solutions", .module = solutions_mod },
        .{ .name = "primeZ", .module = primez_mod },
    };

    addRunnable(b, .test_, "test_solutions", "src/tests/solutions_test.zig", imports);
    addRunnable(b, .bench, "bench_solutions", "src/benches/solutions_bench.zig", imports);
}

// ─────────────────────────────────────────────────────────────────────────────
// TEST / BENCH RUNNER
// ─────────────────────────────────────────────────────────────────────────────

/// Tests and benches only differ in how the module gets built (b.addTest vs.
/// b.addExecutable) and which optimize mode + top-level step they attach to.
/// Everything else — module wiring, install step, run step — is identical,
/// so it's handled here once instead of in two near-duplicate functions.
fn addRunnable(
    b: *std.Build,
    kind: enum { test_, bench },
    comptime name: []const u8,
    comptime path: []const u8,
    imports: []const std.Build.Module.Import,
) void {
    const root_module = b.createModule(.{
        .root_source_file = b.path(path),
        .target = b.graph.host,
        .optimize = if (kind == .test_) .Debug else .ReleaseFast,
        .imports = imports,
    });

    const artifact = switch (kind) {
        .test_ => b.addTest(.{ .name = name, .root_module = root_module }),
        .bench => b.addExecutable(.{ .name = name, .root_module = root_module }),
    };
    b.installArtifact(artifact);

    const run = b.addRunArtifact(artifact);

    switch (kind) {
        .test_ => {
            const test_step = b.step("test", "Run all tests");
            test_step.dependOn(&run.step);

            const install_test_step = b.step("install_tests", "Install test binaries to zig-out/tests/");
            install_test_step.dependOn(&b.addInstallArtifact(artifact, .{
                .dest_dir = .{ .override = .{ .custom = "tests" } },
            }).step);
        },
        .bench => {
            const bench_step = b.step("bench", "Run all benchmarks");
            bench_step.dependOn(&run.step);

            b.step("bench_" ++ name["bench_".len..], "Run the " ++ name ++ " benchmark")
            .dependOn(&run.step);
        },
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