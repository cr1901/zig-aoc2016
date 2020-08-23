const std = @import("std");
const assert = std.debug.assert;
const mem = std.mem;

const KeyPad = struct {
    num: u8 = 5,

    const Dir = enum {
        Up,
        Down,
        Left,
        Right
    };

    pub fn move(self: *KeyPad, d: Dir) !void {
        if((self.num < 1) or (self.num > 9)) {
            return error.InvalidDigit;
        }

        switch(d) {
            .Up => {
                self.move_up();
            },
            .Down => {
                self.move_down();
            },
            .Left => {
                self.move_left();
            },
            .Right => {
                self.move_right();
            }
        }
    }

    fn move_up(self: *KeyPad) void {
        switch(self.num) {
            1...3 => {},
            4...9 => self.num -= 3,
            else => unreachable
        }
    }

    fn move_down(self: *KeyPad) void {
        switch(self.num) {
            7...9 => {},
            1...6 => self.num += 3,
            else => unreachable
        }
    }

    fn move_left(self: *KeyPad) void {
        switch(self.num) {
            1, 4, 7 => {},
            // ./day2/day2.zig:54:49: error: expected token ';', found '}'
            // 2, 5, 8, 3, 6, 9 => { self.num -= 1 },
            2, 5, 8, 3, 6, 9 => { self.num -= 1; },
            else => unreachable
        }
    }

    fn move_right(self: *KeyPad) void {
        switch(self.num) {
            3, 6, 9 => {},
            1, 4, 7, 2, 5, 8 => { self.num += 1; },
            else => unreachable
        }
    }
};

test "keypad" {
    var kp = KeyPad {};

    assert(kp.num == 5);
    kp.move(.Up) catch unreachable;
    assert(kp.num == 2);
    kp.move(.Up) catch unreachable;
    assert(kp.num == 2);
    kp.move(.Left) catch unreachable;
    assert(kp.num == 1);
    kp.move(.Left) catch unreachable;
    assert(kp.num == 1);
    kp.move(.Right) catch unreachable;
    assert(kp.num == 2);
    kp.move(.Right) catch unreachable;
    assert(kp.num == 3);
    kp.move(.Right) catch unreachable;
    assert(kp.num == 3);
    kp.move(.Down) catch unreachable;
    assert(kp.num == 6);
    kp.move(.Down) catch unreachable;
    assert(kp.num == 9);
    kp.move(.Down) catch unreachable;
    assert(kp.num == 9);
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
    var kp = KeyPad {};

    for (buf) |val| {
        // try stdout.print("{}\n", .{token});

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
                try stdout.print("{}\n", .{kp.num});
            },
            else => {
                return error.BadDirection;
            }
        }
    }
}
