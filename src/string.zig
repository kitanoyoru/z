const std = @import("std");

pub fn randomString(allocator: std.mem.Allocator, size: usize, charset: []const u8) ![]const u8 {
    if (size == 0) {
        return error.InvalidSize;
    }
    if (charset.len == 0) {
        return error.EmptyString;
    }

    const buffer = try allocator.alloc(u8, size);

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

    return buffer;
}

pub fn chunkString(allocator: std.mem.Allocator, s: []const u8, size: usize) ![]const []const u8 {
    if (size == 0) {
        return error.InvalidSize;
    }
    if (s.len == 0) {
        return error.EmptyString;
    }

    const num_chunks = (s.len + size - 1) / size;
    var chunks = try allocator.alloc([]const u8, num_chunks);

    var chunk_idx: usize = 0;
    while (chunk_idx < num_chunks) {
        const start_idx = chunk_idx * size;
        const end_idx = @min(start_idx + size, s.len);
        chunks[chunk_idx] = s[start_idx..end_idx];
        chunk_idx += 1;
    }

    return chunks;
}

test "randomString: should generate without errors" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    const size = 10;

    const result = randomString(allocator, size, charset) catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return;
    };
    defer allocator.free(result);

    std.testing.expect(result.len == 10) catch {
        std.debug.print("Error: wrong generated size\n", .{});
        return;
    };
}

test "chunkString: should return without errors" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const input_str = "Hello, World!";
    const chunk_size: usize = 5;

    const chunks = try chunkString(allocator, input_str, chunk_size);
    defer allocator.free(chunks);

    try std.testing.expect(chunks.len == 3);
    try std.testing.expectEqualSlices(u8, chunks[0], "Hello");
    try std.testing.expectEqualSlices(u8, chunks[1], ", Wor");
    try std.testing.expectEqualSlices(u8, chunks[2], "ld!");
}

test "chunkString: should return error.EmptyString" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const input_str = "";
    const chunk_size: usize = 5;

    const result = chunkString(allocator, input_str, chunk_size);

    return std.testing.expectError(error.EmptyString, result);
}

test "chunkString: should return error.InvalidSize" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const input_str = "Hello, World!";
    const chunk_size: usize = 0;

    const result = chunkString(allocator, input_str, chunk_size);

    return std.testing.expectError(error.InvalidSize, result);
}
