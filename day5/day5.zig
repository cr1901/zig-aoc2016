const std = @import("std");
const Md5 = std.crypto.hash.Md5;
const mem = std.mem;
const fmt = std.fmt;
const expectEqual = std.testing.expectEqual;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("AOC 2016 Day 5\n", .{});

    var pass: [4]u8 = undefined;
    var input = "cxdnnyjw";

    try find_password(input, &pass);
    try stdout.print("{X}\n", .{pass});
}

fn find_password(id: []const u8, pass: *[4]u8) !void {
    var idx : u32 = 0;
    var num_chars: u8 = 0;

    const stdout = std.io.getStdOut().writer();

    next: while(num_chars < 8) : (num_chars += 1) {
        while(true) : (idx += 1) {
            if(try find_candidate(id, idx)) |c| {
                if(num_chars % 2 == 1) {
                    pass[num_chars / 2] |= c;
                } else {
                    pass[num_chars / 2] = 0;
                    pass[num_chars / 2] = c << 4;
                }

                idx += 1;
                continue :next;
            }
        }
    }
}

fn find_candidate(id: []const u8, num: u32) !?u8 {
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
        return out[2] & 0x0f;
    } else {
        return null;
    }
}

test "abc" {
    const stdout = std.io.getStdOut().writer();

    var pass: [4]u8 = undefined;
    try find_password("abc", &pass);
    try stdout.print("{X}\n", .{pass});
}
