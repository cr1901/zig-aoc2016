const std = @import("std");
const Regex = @import("regex").Regex;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("AOC 2016 Day 4\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var re = try Regex.compile(&gpa.allocator, "\\w+");
    defer re.deinit();
}
