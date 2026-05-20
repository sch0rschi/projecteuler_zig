const Triplet = @import("triplet.zig").Triplet;

pub const R: Triplet = Triplet{
    .a = 3,
    .b = 4,
    .c = 5,
};

pub fn expand(t: Triplet) struct { Triplet, Triplet, Triplet } {
    const a = t.a;
    const b = t.b;
    const c = t.c;

    return .{
        Triplet{
            .a = a - 2 * b + 2 * c,
            .b = 2 * a - b + 2 * c,
            .c = 2 * a - 2 * b + 3 * c,
        },
        Triplet{
            .a = a + 2 * b + 2 * c,
            .b = 2 * a + b + 2 * c,
            .c = 2 * a + 2 * b + 3 * c,
        },
        Triplet{
            .a = -a + 2 * b + 2 * c,
            .b = -2 * a + b + 2 * c,
            .c = -2 * a + 2 * b + 3 * c,
        },
    };
}
