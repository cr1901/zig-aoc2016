const std = @import("std");
const Md5 = std.crypto.hash.Md5;
const mem = std.mem;
const fmt = std.fmt;
const expectEqual = std.testing.expectEqual;

const ImpliedPos = struct {
    pass: [4]u8 = undefined,
    count: u8 = 0,
    ready: bool = false,

    fn add_char(self: *ImpliedPos, candidate: [2]u8) !void {
        const stdout = std.io.getStdOut().writer();

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

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("AOC 2016 Day 5\n", .{});

    var input = "cxdnnyjw";

    var strat = ImpliedPos{};
    try find_password(ImpliedPos, &strat, input);
    try stdout.print("{X}\n", .{strat.pass});
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
}
