const std = @import("std");

const test_targets = [_]std.Target.Query{
    .{}, // native
};
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "z",
        .root_source_file = b.path("lib/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib);

    const test_step = b.step("test", "Run unit tests");
    for (test_targets) |test_target| {
        const lib_string_unit_tests = b.addTest(.{
            .root_source_file = b.path("lib/string.zig"),
            .target = b.resolveTargetQuery(test_target),
        });
        const lib_find_unit_tests = b.addTest(.{
            .root_source_file = b.path("lib/find.zig"),
            .target = b.resolveTargetQuery(test_target),
        });

        const run_string_lib_unit_tests = b.addRunArtifact(lib_string_unit_tests);
        const run_find_lib_unit_tests = b.addRunArtifact(lib_find_unit_tests);

        test_step.dependOn(&run_string_lib_unit_tests.step);
        test_step.dependOn(&run_find_lib_unit_tests.step);
    }
}
