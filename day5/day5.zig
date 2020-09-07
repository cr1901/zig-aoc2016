const std = @import("std");
const Md5 = std.crypto.hash.Md5;
const mem = std.mem;
const fmt = std.fmt;
const expectEqual = std.testing.expectEqual;
const AutoHashMap = std.hash_map.AutoHashMap;
const Allocator = std.mem.Allocator;

const ImpliedPos = struct {
    pass: [4]u8 = undefined,
    count: u8 = 0,
    ready: bool = false,

    fn add_char(self: *ImpliedPos, candidate: [2]u8) !void {
        if(candidate[0] >= 16) {
            return error.OutOfRange;
        }

        if(self.count % 2 == 1) {
            self.pass[self.count / 2] |= candidate[0];
        } else {
            self.pass[self.count / 2] = 0;
            self.pass[self.count / 2] = candidate[0] << 4;
        }

        self.count += 1;
        self.ready = (self.count >= 8);
    }
};

const CalcPos = struct {
    pass: [4]u8 = undefined,
    seen: AutoHashMap(u8, u8),
    count: u8 = 0,
    ready: bool = false,

    fn init(a: *Allocator) CalcPos {
        var seen = AutoHashMap(u8, u8).init(a);

        return CalcPos {
            .seen = seen
        };
    }

    fn add_char(self: *CalcPos, candidate: [2]u8) !void {
        var pos = candidate[0];
        var char = candidate[1];

        if(pos >= 8) {
            return;
        }

        if(char >= 16) {
            return error.OutOfRange;
        }

        var res = try self.seen.getOrPut(pos);
        if(res.found_existing) {
            return;
        } else {
            res.entry.value = char;
            self.count += 1;
        }

        if(self.count >= 8) {
            var curr_count: u8 = 0;

            while(curr_count < self.count) : (curr_count += 1) {
                var curr_char = try self.seen.getOrPut(curr_count);

                if(curr_count % 2 == 1) {
                    self.pass[curr_count / 2] |= curr_char.entry.value;
                } else {
                    self.pass[curr_count / 2] = 0;
                    self.pass[curr_count / 2] = curr_char.entry.value << 4;
                }
            }

            self.ready = true;
        }
    }

    fn deinit(self: *CalcPos) void {
        self.seen.deinit();
    }
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("AOC 2016 Day 5\n", .{});

    var input = "cxdnnyjw";

    var strat = ImpliedPos{};
    try find_password(ImpliedPos, &strat, input);
    try stdout.print("{X}\n", .{strat.pass});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var new_strat = CalcPos.init(&gpa.allocator);
    defer _ = gpa.deinit();
    defer new_strat.deinit();

    try find_password(CalcPos, &new_strat, input);
    try stdout.print("{X}\n", .{new_strat.pass});
}

fn find_password(comptime T: type, strategy: *T, id: []const u8) !void {
    var idx : u32 = 0;

    // ./day5/day5.zig:50:13: error: container 'ImpliedPos' has no member called 'ready'
    // while(!T.ready) {
    while(!strategy.ready) : (idx += 1) {
        if(try find_candidate(id, idx)) |c| {
            try strategy.add_char(c);

        }
    }
}

fn find_candidate(id: []const u8, num: u32) !?[2]u8 {
    var buf: [24]u8 = undefined;
    var out: [16]u8 = undefined;

    var id_len = id.len;

    if(id_len >= 24) {
        return error.IdTooLong;
    }

    mem.copy(u8, &buf, id);
    var buf_len = id_len + (try fmt.bufPrint(buf[id_len..], "{}", .{num})).len;

    Md5.hash(buf[0..buf_len], &out, .{});

    if(out[0] == 0 and out[1] == 0 and (out[2] >> 4) == 0) {
        var chars: [2]u8 = [2]u8{out[2] & 0x0f, out[3] >> 4};
        return chars;
    } else {
        return null;
    }
}

test "abc" {
    const stdout = std.io.getStdOut().writer();

    var strat = ImpliedPos{};
    try find_password(ImpliedPos, &strat, "abc");
    try stdout.print("{X}\n", .{strat.pass});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var new_strat = CalcPos.init(&gpa.allocator);
    defer _ = gpa.deinit();
    defer new_strat.deinit();
    try find_password(CalcPos, &new_strat, "abc");
    try stdout.print("{X}\n", .{new_strat.pass});
}
