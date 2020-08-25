const std = @import("std");
const keypads = @import("keypads.zig");
const mem = std.mem;

test "main" {
    _ = @import("keypads.zig");
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("AOC 2016 Day 2\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const buf = try std.fs.cwd().readFileAlloc(&gpa.allocator, "day2/input.1", 4096);
    defer gpa.allocator.free(buf);

    var kp = keypads.KeyPad(
        \\123
        \\456
        \\789
    , '5'){};
    var skp = keypads.KeyPad(
        \\  1  
        \\ 234 
        \\56789
        \\ ABC 
        \\  D  
    , '5'){};
    try solve(&kp, buf); // Part 1
    try solve(&skp, buf); // Part 2
}

fn solve(kp: anytype, buf: []const u8) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{} Code: ", .{@typeName(@TypeOf(kp).Child)});

    for (buf) |val| {
        switch (val) {
            'U' => kp.move(.Up),
            'D' => kp.move(.Down),
            'L' => kp.move(.Left),
            'R' => kp.move(.Right),
            '\n' => {
                try stdout.print("{c}", .{kp.num});
            },
            else => {
                return error.BadDirection;
            },
        }
    }
    try stdout.print("\n", .{});
}
