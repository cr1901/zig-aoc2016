const std = @import("std");
const File = std.fs.File;
const mem = std.mem;
const sort = std.sort.sort;

const asc_u16 = std.sort.asc(u16);

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("AOC 2016 Day 3\n", .{});

    const allocator: *std.mem.Allocator = std.heap.page_allocator;
    const buf = try std.fs.cwd().readFileAlloc(allocator, "day3/input.1", 1024*24);
    defer allocator.free(buf);

    var line_it = mem.tokenize(buf, "\n");
    var possible_tris : u16 = 0;

    while(line_it.next()) |line| {
        var int_it = mem.tokenize(line, " ");

        var cnt : u8 = 0;
        var sizes: [3]u16 = [3]u16{ 0, 0, 0 };

        while(int_it.next()) |token| {
            sizes[cnt] = try std.fmt.parseInt(u16, token, 10);
            cnt += 1;
        }

        if(cnt != 3) {
            return error.TooManyInts;
        }

        // const asc_u16 = std.sort.asc(u16);
        // ./day3/day3.zig:35:36: error: unable to evaluate constant expression
        sort(u16, sizes[0..], {}, asc_u16);

        if(sizes[0] + sizes[1] > sizes[2]) {
            possible_tris += 1;
        }
    }

    try stdout.print("Possible Triangles Total: {}\n", .{possible_tris });
}
