const std = @import("std");
const File = std.fs.File;
const mem = std.mem;
const sort = std.sort.sort;

const asc_u16 = std.sort.asc(u16);

const TriIterator = struct {
    buf: []const u8,
    line_it: std.mem.TokenIterator,

    pub fn init(buf: []const u8) TriIterator {
        return .{
            .buf = buf,
            .line_it = mem.tokenize(buf, "\n")
        };
    }

    pub fn next(self: *TriIterator) ?[3] u16 {
        if(self.line_it.next()) |line| {
            var cnt : u8 = 0;
            var sizes: [3]u16 = [3]u16{ 0, 0, 0 };
            var int_it = mem.tokenize(line, " ");

            while(int_it.next()) |token| : (cnt += 1) {
                sizes[cnt] = std.fmt.parseInt(u16, token, 10) catch return null;
            }

            return sizes;
        } else {
            return null;
        }
    }
};

const TriColIterator = struct {
    buf: []const u8,
    line_it: std.mem.TokenIterator,
    chunk: [9]u16,
    offs: u8,

    pub fn init(buf: []const u8) TriColIterator {
        return .{
            .buf = buf,
            .line_it = mem.tokenize(buf, "\n"),
            .chunk = .{ 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            .offs = 0
        };
    }

    pub fn next(self: *TriColIterator) ?[3] u16 {
        var i: u8 = 0;

        const stdout = std.io.getStdOut().writer();

        if(self.offs == 0) {
            while(i < 3) : (i += 1) {
                if(self.line_it.next()) |line| {
                    var cnt : u8 = i;
                    var int_it = mem.tokenize(line, " ");

                    stdout.print("{}\n", .{line}) catch unreachable;

                    while(int_it.next()) |token| : (cnt += 3) {
                        self.chunk[cnt] = std.fmt.parseInt(u16, token, 10) catch return null;
                    }
                } else {
                    return null;
                }
            }
        }
        // Compiler wants return at end of function, not inside else.
        // else {
        var sizes: [3]u16 = [3]u16{0, 0, 0};
        for(self.chunk[self.offs..self.offs+3]) |w, idx| sizes[idx] = w;

        // Operator precedence!
        // self.offs = (self.offs + 3) % @sizeOf(@TypeOf(self.chunk))/@sizeOf(u16);
        self.offs = (self.offs + 3) % @typeInfo(@TypeOf(self.chunk)).Array.len;
        return sizes;
        // }
    }
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("AOC 2016 Day 3\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const buf = try std.fs.cwd().readFileAlloc(&gpa.allocator, "day3/input.1", 1024 * 24);
    defer gpa.allocator.free(buf);

    var tri_it = TriIterator.init(buf);
    try solve(TriIterator, &tri_it);
    var col_it = TriColIterator.init(buf);
    try solve(TriColIterator, &col_it);
}

fn solve(comptime T: type, tri_it: *T) !void {
    const stdout = std.io.getStdOut().writer();
    var possible_tris: u16 = 0;

    while (tri_it.next()) |*tri| {
        // const asc_u16 = std.sort.asc(u16);
        // ./day3/day3.zig:35:36: error: unable to evaluate constant expression
        sort(u16, tri[0..], {}, asc_u16);

        if (tri[0] + tri[1] > tri[2]) {
            possible_tris += 1;
        }
    }

    try stdout.print("Possible Triangles Total: {}\n", .{possible_tris});
}
