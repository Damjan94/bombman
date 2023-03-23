const std = @import("std");

// we build raylib here, but this does take care of everything we need to do for this.
const addRaylib = @import("raylib/src/build.zig").addRaylib;

fn createModule(b: *std.build.Builder, relativePath: []const u8) *std.build.Module {
    return b.createModule(.{ .source_file = std.build.FileSource.relative(relativePath) });
}

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const raylib = addRaylib(b, target, optimize);
    const raylibModule = createModule(b, "src/raylib.zig");
    const animationModule = createModule(b, "src/animation.zig");
    try animationModule.dependencies.put("raylib", raylibModule);
    const resourceModule = createModule(b, "src/resource/resource_manager.zig");
    try resourceModule.dependencies.put("raylib", raylibModule);
    const exe = b.addExecutable(.{
        .name = "bombman",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.addModule("raylib", raylibModule);
    exe.addModule("animation", animationModule);
    exe.addModule("resource", resourceModule);
    exe.linkLibrary(raylib);
    exe.addIncludePath("raylib/src");
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing.
    const exe_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe_tests.addModule("raylib", raylibModule);
    exe_tests.addModule("animation", animationModule);
    exe_tests.addModule("resource", resourceModule);
    exe_tests.linkLibrary(raylib);
    exe_tests.addIncludePath("raylib/src");

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
