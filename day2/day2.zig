const std = @import("std");
const keypads = @import("keypads.zig");
const mem = std.mem;

test "main" {
    _ = @import("keypads.zig");
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("AOC 2016 Day 2\n", .{});

    const allocator: *std.mem.Allocator = std.heap.page_allocator;
    const buf = try std.fs.cwd().readFileAlloc(allocator, "day2/input.1", 4096);
    defer allocator.free(buf);

    var kp = keypads.KeyPad {};
    var skp = keypads.SuperKeyPad {};
    try solve(keypads.KeyPad, &kp, buf); // Part 1
    try solve(keypads.SuperKeyPad, &skp, buf); // Part 2
}

// ./day2/day2.zig:28:17: error: expected type '*keypads.KeyPad', found '*const keypads.KeyPad'
// try part1(keypads.KeyPad, kp, buf);
// fn part1(comptime T: type, kp: T, buf: []const u8) !void {
fn solve(comptime T: type, kp: *T, buf: []const u8) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{} Code: ", .{ @typeName(T) });

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
                try stdout.print("{X}", .{kp.num});
            },
            else => {
                return error.BadDirection;
            }
        }
    }
    try stdout.print("\n", .{});
}
