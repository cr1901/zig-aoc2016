const std = @import("std");
const Builder = std.build.Builder;
const fmt = std.fmt;
const printerr = std.debug.print;

pub fn build(b: *Builder) void {
    // error: array literal requires address-of operator to coerce to slice type '[][]const u8'
    // var days: [][]const u8 = [_][]const u8{"day1", "day2"};

    var days = [_][]const u8{"day1", "day2"};
    var day_no: i32 = 1;
    const allocator: *std.mem.Allocator = std.heap.page_allocator;

    for (days) |day| {
        // Oops...
        // var path_buf: [100]u8 = undefined;

        var path_buf: []u8 = allocator.alloc(u8, 100) catch {
            printerr("Error allocating memory for {}.", .{day});
            return;
        };

        var msg_buf: []u8 = allocator.alloc(u8, 100) catch {
            printerr("Error allocating msg for {}.", .{day});
            return;
        };

        const path_name = fmt.bufPrint(path_buf[0..], "{}/{}.zig", .{ day, day }) catch unreachable;
        const day_exe = b.addExecutable(day, path_name);
        day_exe.setBuildMode(b.standardReleaseOptions());

        const day_cmd = day_exe.run();
        const run_msg = fmt.bufPrint(msg_buf[0..], "Run AOC 2016 Day {} Program", .{ day_no }) catch unreachable;
        const day_step = b.step(day, run_msg);
        day_step.dependOn(&day_cmd.step);

        day_no += 1;
    }
}
