const std = @import("std");
const File = std.fs.File;
const mem = std.mem;
const maxInt = std.math.maxInt;

const Dir = enum {
    North,
    South,
    East,
    West
};

const Turn = enum {
    Left,
    Right
};

const Coords = struct {
    x: i16 = 0,
    y: i16 = 0,
    dir: Dir = .North,

    pub fn move(self: *Coords, turn: Turn, dist: u16) void {
        switch(turn) {
            .Left => {
                self.turnCClk();
            },
            .Right => {
                self.turnClk();
            }
        }

        switch(self.dir) {
            .North => self.y += @intCast(i16, dist),
            .South => self.y -= @intCast(i16, dist),
            .East => self.x += @intCast(i16, dist),
            .West => self.x -= @intCast(i16, dist),
        }
    }

    pub fn taxicab(self: Coords) u16 {
        var abs_x = @intCast(u16, if(self.x < 0) -self.x else self.x);
        var abs_y = @intCast(u16, if(self.y < 0) -self.y else self.y);

        //./day1/day1.zig:46:17: error: expression value is ignored
        //        -self.y;
        // var abs_y = {
        //     if(self.y < 0) {
        //         -self.y
        //     } else {
        //         self.y
        //     };
        // };

        return abs_x + abs_y;
    }

    fn turnClk(self: *Coords) void {
        switch(self.dir) {
            .North => self.dir = .East,
            .East => self.dir = .South,
            .South => self.dir = .West,
            .West => self.dir = .North
        }
    }

    fn turnCClk(self: *Coords) void {
        switch(self.dir) {
            .North => self.dir = .West,
            .West => self.dir = .South,
            .South => self.dir = .East,
            .East => self.dir = .North
        }
    }
};


// Stolen from: https://ziglang.org/documentation/master/#Error-Union-Type
pub fn parseU16(buf: []const u8, radix: u8) !u16 {
    var x: u16 = 0;

    for (buf) |c| {
        const digit = charToDigit(c);

        if (digit >= radix) {
            return error.InvalidChar;
        }

        // x *= radix
        if (@mulWithOverflow(u16, x, radix, &x)) {
            return error.Overflow;
        }

        // x += digit
        if (@addWithOverflow(u16, x, digit, &x)) {
            return error.Overflow;
        }
    }

    return x;
}

fn charToDigit(c: u8) u8 {
    return switch (c) {
        '0' ... '9' => c - '0',
        'A' ... 'Z' => c - 'A' + 10,
        'a' ... 'z' => c - 'a' + 10,
        else => maxInt(u8),
    };
}


pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("AOC 2016 Day 1\n", .{});

    const allocator: *std.mem.Allocator = std.heap.page_allocator;
    const buf = try std.fs.cwd().readFileAlloc(allocator, "day1/input.1", 1024);

    var it = mem.tokenize(buf, ", \n");
    // ./day1/day1.zig:13:5: error: type '?[]const u8' does not support field access
    // for(it.next()) |token| {

    var coords = Coords {};

    while (it.next()) |token| {
        // try stdout.print("{}\n", .{token});

        switch(token[0]) {
            'R' => {
                var dist = try parseU16(token[1..], 10);
                coords.move(.Right, dist);
            },
            'L' => {
                var dist = try parseU16(token[1..], 10);
                coords.move(.Left, dist);
            },
            else => {
                return error.BadDirection;
            }
        }
    }

    try stdout.print("Distance to HQ: {}\n", .{coords.taxicab()});
}
