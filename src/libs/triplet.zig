pub const Triplet = struct {
    a: i32,
    b: i32,
    c: i32,

    pub fn sum(self: Triplet) usize {
        return @as(usize, @intCast(self.a + self.b + self.c));
    }

    pub fn product(self: Triplet) usize {
        return @as(usize, @intCast(self.a * self.b * self.c));
    }
};
