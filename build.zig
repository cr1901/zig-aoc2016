const std = @import("std");
const Builder = std.build.Builder;
const LibExeObjStep  = std.build.LibExeObjStep;
const fmt = std.fmt;

pub fn build(b: *Builder) void {
    var buf = [_]u8{undefined} ** 100;

    for ([_][]const u8{ "day1", "day2", "day3", "day4" }) |day, ix| {
        var day_no = ix + 1;

        const path_name = fmt.bufPrint(&buf, "{}/{}.zig", .{ day, day }) catch unreachable;
        const day_exe = b.addExecutable(day, b.dupe(path_name));
        day_exe.setBuildMode(b.standardReleaseOptions());
        add_extern(b, day_exe);

        const day_cmd = day_exe.run();
        const run_msg = fmt.bufPrint(&buf, "Run AOC 2016 Day {} Program", .{day_no}) catch unreachable;
        const day_step = b.step(day, b.dupe(run_msg));
        day_step.dependOn(&day_cmd.step);
    }
}

// Add external libraries used here- there are available as submodules under extern.
fn add_extern(b: *Builder, e: *LibExeObjStep) void {
    for ([_][2][]const u8{
            [2][]const u8{"regex", "extern/zig-regex/src/regex.zig"},

        }) |lib_path| {

        e.addPackagePath(lib_path[0], lib_path[1]);
    }
}
