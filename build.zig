const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const day1 = b.addExecutable("day1", "day1/day1.zig");
    day1.setBuildMode(b.standardReleaseOptions());

    const day1_cmd = day1.run();
    const day1_step = b.step("day1", "Run AOC 2016 Day 1 Program");
    day1_step.dependOn(&day1_cmd.step);

    const day2 = b.addExecutable("day2", "day2/day2.zig");
    day2.setBuildMode(b.standardReleaseOptions());

    const day2_cmd = day2.run();
    const day2_step = b.step("day2", "Run AOC 2016 Day 2 Program");
    day2_step.dependOn(&day2_cmd.step);
}
