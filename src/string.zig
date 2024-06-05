const std = @import("std");

pub fn randomString(allocator: std.mem.Allocator, size: u32, charset: []const u8) ![]const u8 {
    if (size == 0) {
        return error.InvalidSize;
    }
    if (charset.len == 0) {
        return error.InvalidCharset;
    }

    const buffer = try allocator.alloc(u8, size);
    defer allocator.free(buffer);

    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });

    var rand = prng.random();

    for (buffer) |*ch| {
        const idx = rand.int(u64) % charset.len;
        ch.* = charset[idx];
    }

    const result = try allocator.dupe(u8, buffer);

    return result;
}

test "should generate random string with specified charset" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    const size = 10;

    const result = randomString(allocator, size, charset) catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return;
    };

    std.testing.expect(result.len == 10) catch {
        std.debug.print("Error: wrong generated size\n", .{});
        return;
    };
}
