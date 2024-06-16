const std = @import("std");

pub fn indexOf(comptime T: type, collection: []T, element: T) !usize {
    const is_ptr = switch (@typeInfo(T)) {
        .Pointer => true,
        else => false,
    };

    for (0.., collection) |idx, item| {
        var is_equal: bool = false;

        if (is_ptr) {
            is_equal = std.mem.eql(@typeInfo(T).Pointer.child, item, element);
        } else {
            is_equal = item == element;
        }

        if (is_equal) {
            return idx;
        }
    }

    return error.ElementNotFound;
}

test "indexOf: should correctly find i32" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const collection = try allocator.alloc(i32, 5);
    defer allocator.free(collection);

    collection[2] = 3;

    const index = indexOf(i32, collection, 3);

    try std.testing.expectEqual(@as(usize, 2), index);
}

test "indexOf: should return error.ElementNotFound for i32" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const collection = try allocator.alloc(i32, 5);
    defer allocator.free(collection);

    collection[2] = 3;

    const result = indexOf(i32, collection, 5);

    return std.testing.expectError(error.ElementNotFound, result);
}

test "indexOf: should correctly find []const u8" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const collection = try allocator.alloc([]const u8, 5);
    defer allocator.free(collection);

    collection[2] = "hello";

    const index = indexOf([]const u8, collection, "hello");

    try std.testing.expectEqual(@as(usize, 2), index);
}

test "indexOf: should return error.ElementNotFound for []const u8" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const collection = try allocator.alloc([]const u8, 5);
    defer allocator.free(collection);

    collection[2] = "hello";

    const result = indexOf([]const u8, collection, "world");

    return std.testing.expectError(error.ElementNotFound, result);
}
