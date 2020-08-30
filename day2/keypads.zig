const std = @import("std");
const assert = std.debug.assert;

pub fn KeyPad(comptime map: []const u8, start: u8) type {
    var rows: []const []const u8 = &[_][]const u8{};
    var it = std.mem.tokenize(map, "\n");
    while (it.next()) |row| {
        rows = rows ++ [_][]const u8{row};
    }

    var start_x: u8 = undefined;
    var start_y: u8 = undefined;

    find_start: {
        for (rows) |row, y| {
            for (row) |c, x| {
                if (c == start) {
                    start_x = x;
                    start_y = y;
                    break :find_start;
                }
            }
        }

        @compileError("couldn't find start in map");
    }

    return struct {
        const Self = @This();

        x: u8 = start_x,
        y: u8 = start_y,
        num: u8 = rows[start_y][start_x],

        pub const Dir = enum {
            Up, Down, Left, Right
        };

        pub fn move(self: *Self, d: Dir) void {
            switch (d) {
                .Up => self.move_up(),
                .Down => self.move_down(),
                .Left => self.move_left(),
                .Right => self.move_right(),
            }
            self.num = rows[self.y][self.x];
        }

        fn move_up(self: *Self) void {
            if (self.y == 0 or rows[self.y - 1][self.x] == ' ') return;
            self.y -= 1;
        }

        fn move_down(self: *Self) void {
            if (self.y == rows.len - 1 or rows[self.y + 1][self.x] == ' ') return;
            self.y += 1;
        }

        fn move_left(self: *Self) void {
            if (self.x == 0 or rows[self.y][self.x - 1] == ' ') return;
            self.x -= 1;
        }

        fn move_right(self: *Self) void {
            if (self.x == rows[self.y].len - 1 or rows[self.y][self.x + 1] == ' ') return;
            self.x += 1;
        }
    };
}

test "keypad" {
    var kp = KeyPad("123\n456\n789", '5'){};

    assert(kp.num == '5');
    kp.move(.Up);
    assert(kp.num == '2');
    kp.move(.Up);
    assert(kp.num == '2');
    kp.move(.Left);
    assert(kp.num == '1');
    kp.move(.Left);
    assert(kp.num == '1');
    kp.move(.Right);
    assert(kp.num == '2');
    kp.move(.Right);
    assert(kp.num == '3');
    kp.move(.Right);
    assert(kp.num == '3');
    kp.move(.Down);
    assert(kp.num == '6');
    kp.move(.Down);
    assert(kp.num == '9');
    kp.move(.Down);
    assert(kp.num == '9');
}
