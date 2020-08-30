const std = @import("std");
const File = std.fs.File;
const mem = std.mem;
const maxInt = std.math.maxInt;
const hash_map = std.hash_map;

const Dir = enum {
    North, South, East, West
};

const Turn = enum {
    Left, Right, None
};

const Coords = struct {
    x: i16 = 0,
    y: i16 = 0,
    dir: Dir = .North,

    pub fn move(self: *Coords, turn: Turn, dist: u16) void {
        switch (turn) {
            .Left => {
                self.turnCClk();
            },
            .Right => {
                self.turnClk();
            },
            .None => {},
        }

        switch (self.dir) {
            .North => self.y += @intCast(i16, dist),
            .South => self.y -= @intCast(i16, dist),
            .East => self.x += @intCast(i16, dist),
            .West => self.x -= @intCast(i16, dist),
        }
    }

    pub fn taxicab(self: Coords) u16 {
        return std.math.absCast(self.x) + std.math.absCast(self.y);
    }

    fn turnClk(self: *Coords) void {
        switch (self.dir) {
            .North => self.dir = .East,
            .East => self.dir = .South,
            .South => self.dir = .West,
            .West => self.dir = .North,
        }
    }

    fn turnCClk(self: *Coords) void {
        switch (self.dir) {
            .North => self.dir = .West,
            .West => self.dir = .South,
            .South => self.dir = .East,
            .East => self.dir = .North,
        }
    }
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("AOC 2016 Day 1\n", .{});

    const allocator: *std.mem.Allocator = std.heap.page_allocator;
    const buf = try std.fs.cwd().readFileAlloc(allocator, "day1/input.1", 1024);
    defer allocator.free(buf);

    try part1(buf);
    try part2(buf);
}

fn part1(buf: []const u8) !void {
    const stdout = std.io.getStdOut().writer();
    var it = mem.tokenize(buf, ", \n");

    var coords = Coords{};

    while (it.next()) |token| {
        // try stdout.print("{}\n", .{token});
        switch (token[0]) {
            'R' => {
                var dist = try std.fmt.parseInt(u16, token[1..], 10);
                coords.move(.Right, dist);
            },
            'L' => {
                var dist = try std.fmt.parseInt(u16, token[1..], 10);
                coords.move(.Left, dist);
            },
            else => {
                return error.BadDirection;
            },
        }
    }

    try stdout.print("Distance to HQ: {}\n", .{coords.taxicab()});
}

fn part2(buf: []const u8) !void {
    const stdout = std.io.getStdOut().writer();
    var it = mem.tokenize(buf, ", \n");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    // Use HashMap as a set.
    const Loc = struct { x: i16 = 0, y: i16 = 0 };
    var seen = hash_map.AutoHashMap(Loc, void).init(&gpa.allocator);
    defer seen.deinit();

    var coords = Coords{};
    var curr_loc = Loc{};

    search: while (it.next()) |token| {
        var dist: u16 = undefined;

        switch (token[0]) {
            'R' => {
                dist = try std.fmt.parseInt(u16, token[1..], 10);
                coords.move(.Right, 1);
            },
            'L' => {
                dist = try std.fmt.parseInt(u16, token[1..], 10);
                coords.move(.Left, 1);
            },
            else => return error.BadDirection,
        }

        var i: u16 = 0;
        while (i < (dist - 1)) : (i += 1) {
            coords.move(.None, 1);
            curr_loc = Loc{ .x = coords.x, .y = coords.y };

            if ((try seen.getOrPut(curr_loc)).found_existing) {
                break :search;
            }
        }
    } else {
        try stdout.print("Actual Location: We didn't visit any location twice!\n", .{});
        return error.UniqueError;
    }

    try stdout.print("Actual Location: ({}, {})\n", .{ coords.x, coords.y });
    try stdout.print("Distance Away: {}\n", .{coords.taxicab()});
}
