const r = @import("raylib.zig");
const std = @import("std");
const t = std.testing;
const assert = std.debug.assert;

const Animation = @This();

const DEFAULT_ANIMATION_SPEED = 0.5;

textures: []const r.Texture,
currentTextureIndex: u8 = 0,
timeElapsed: f32 = 0,
animationSpeed: f32,

pub fn init(textures: []const r.Texture2D) Animation {
    return .{ .textures = textures, .animationSpeed = DEFAULT_ANIMATION_SPEED / @intToFloat(f32, textures.len) };
}

pub fn currentTexture(self: *const Animation) r.Texture2D {
    return self.textures[self.currentTextureIndex];
}
pub fn update(self: *Animation, dt: f32) void {
    self.timeElapsed += dt;
    if (!(self.timeElapsed > self.animationSpeed)) {
        return;
    }
    self.timeElapsed = 0;
    self.currentTextureIndex = @truncate(u8, (self.currentTextureIndex + 1) % self.textures.len);
}

pub fn render(self: *const Animation, position: r.Vector2) void {
    r.DrawTextureV(self.currentTexture(), position, r.RAYWHITE);
}

const mockSprites = [4]r.Texture2D{ std.mem.zeroes(r.Texture2D), std.mem.zeroes(r.Texture2D), std.mem.zeroes(r.Texture2D), std.mem.zeroes(r.Texture2D) };
test "correctlyStartsAnimationAtZeroIndex" {
    var animation = Animation.init(&mockSprites);
    try t.expectEqual(animation.currentTextureIndex, 0);
}
test "correctlyUpdatesIndex" {
    var animation = Animation.init(&mockSprites);
    const frameTime = 0.16;
    animation.update(frameTime);
    try t.expectEqual(animation.currentTextureIndex, 1);
}
