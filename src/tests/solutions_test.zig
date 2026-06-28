const std = @import("std");
const solutions = @import("solutions");

test "Problem 1" {
    try std.testing.expectEqual(@as(u64, 233168), solutions.problem_0001.solve_0001(std.testing.allocator, std.testing.allocator));
}

test "Problem 2" {
    try std.testing.expectEqual(@as(u64, 4613732), solutions.problem_0002.solve_0002(std.testing.allocator, std.testing.allocator));
}

test "Problem 3" {
    try std.testing.expectEqual(@as(u64, 6857), solutions.problem_0003.solve_0003(std.testing.allocator, std.testing.allocator));
}

test "Problem 4" {
    try std.testing.expectEqual(@as(u64, 906609), solutions.problem_0004.solve_0004(std.testing.allocator, std.testing.allocator));
}

test "solve_0005" {
    const result = solutions.problem_0005.solve_0005(std.testing.allocator, std.testing.allocator);
    try std.testing.expectEqual(@as(u32, 232792560), result);
}

test "solve_0006" {
    const result = solutions.problem_0006.solve_0006(std.testing.allocator, std.testing.allocator);
    try std.testing.expectEqual(@as(u32, 25164150), result);
}

test "solve_0007" {
    const result = solutions.problem_0007.solve_0007(std.testing.allocator, std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 104743), result);
}

test "solve_0008" {
    const result = solutions.problem_0008.solve_0008(std.testing.allocator, std.testing.allocator);
    try std.testing.expectEqual(@as(u64, 23514624000), result);
}

test "solve_0009" {
    const result = solutions.problem_0009.solve_0009(std.testing.allocator, std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 31875000), result);
}

test "solve_0010" {
    const result = solutions.problem_0010.solve_0010(std.testing.allocator, std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 142913828922), result);
}

test "solve_0014" {
    const result = solutions.problem_0014.solve_0014(std.testing.allocator, std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 837799), result);
}

test "solve_0058" {
    const result = solutions.problem_0058.solve_0058(std.testing.allocator, std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 26241), result);
}

test "solve_0060" {
    const result = solutions.problem_0060.solve_0060(std.testing.allocator, std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 26033), result);
}

test "solve_0078" {
    const result = solutions.problem_0078.solve_0078(std.testing.allocator, std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 55374), result);
}

test "solve_0095" {
    const result = solutions.problem_0095.solve_0095(std.testing.allocator, std.testing.allocator);
    try std.testing.expectEqual(@as(u32, 14316), result);
}
