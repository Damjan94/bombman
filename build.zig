const std = @import("std");

// we build raylib here, but this does take care of everything we need to do for this.
const addRaylib = @import("raylib/src/build.zig").addRaylib;

// setTarget() must have been called on step before calling this
// fn addRaylibDependencies(step: *std.build.LibExeObjStep, raylib: *std.build.LibExeObjStep) void {
//     step.addIncludePath("raylib/src");

//     // raylib's build.zig file specifies all libraries this executable must be
//     // linked with, so let's copy them from there.
//     for (raylib.link_objects.items) |o| {
//         if (o == .system_lib) {
//             step.linkSystemLibrary(o.system_lib.name);
//         }
//     }
//     if (step.target.isWindows()) {
//         step.addObjectFile("zig-out/lib/raylib.lib");
//     } else {
//         step.addObjectFile("zig-out/lib/libraylib.a");
//     }
// }

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const raylib = addRaylib(b, target, optimize);

    const exe = b.addExecutable(.{
        .name = "bombman",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
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
    exe_tests.linkLibrary(raylib);
    exe_tests.addIncludePath("raylib/src");

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
