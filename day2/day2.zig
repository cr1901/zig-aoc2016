const std = @import("std");
const keypads = @import("keypads.zig");
const mem = std.mem;

test "main" {
    _ = @import("keypads.zig");
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("AOC 2016 Day 2 Stub\n", .{});

    const allocator: *std.mem.Allocator = std.heap.page_allocator;
    const buf = try std.fs.cwd().readFileAlloc(allocator, "day2/input.1", 4096);
    defer allocator.free(buf);

    try part1(buf);
}

fn part1(buf: []const u8) !void {
    const stdout = std.io.getStdOut().writer();
    var kp = keypads.KeyPad {};

    try stdout.print("KeyPad Code: ", .{});

    for (buf) |val| {
        switch(val) {
            'U' => {
                kp.move(.Up) catch unreachable;
            },
            'D' => {
                kp.move(.Down) catch unreachable;
            },
            'L' => {
                kp.move(.Left) catch unreachable;
            },
            'R' => {
                kp.move(.Right) catch unreachable;
            },
            '\n' => {
                try stdout.print("{}", .{kp.num});
            },
            else => {
                return error.BadDirection;
            }
        }
    }
}
