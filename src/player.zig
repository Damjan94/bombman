const std = @import("std");
const t = std.testing;
const FrameInfo = @import("frame_info.zig");
const r = @import("raylib.zig");
const Animation = @import("animation.zig");
const ResourceManager = @import("resource_manager.zig");
const Player = @This();

const AnimationArray = [@typeInfo(MoveDirection).Enum.fields.len]Animation;
pub const MoveDirection = enum(u8) { None, Down, Left, Right, Up };
position: r.Vector2,
velocity: r.Vector2,
animation: AnimationArray,
activeAnimation: *Animation = undefined,

const MOVE_SPEED = 100;

const ZERO = r.Vector2{ .x = 0, .y = 0 };
const DOWN = r.Vector2{ .x = 0, .y = 1 };
const LEFT = r.Vector2{ .x = -1, .y = 0 };
const RIGHT = r.Vector2{ .x = 1, .y = 0 };
const UP = r.Vector2{ .x = 0, .y = -1 };

fn getMoveVector(moveDirection: MoveDirection) r.Vector2 {
    return switch (moveDirection) {
        .None => ZERO,
        .Down => DOWN,
        .Left => LEFT,
        .Right => RIGHT,
        .Up => UP,
    };
}

fn getAnimation(self: *Player, moveDirection: MoveDirection) *Animation {
    return &self.animation[@enumToInt(moveDirection)];
}
fn getForceActingOnPlayer(frameInfo: *const FrameInfo) r.Vector2 {
    const vector = getMoveVector(frameInfo.moveDirection);
    const force = r.Vector2Scale(vector, MOVE_SPEED);
    const momentForce = r.Vector2Scale(force, frameInfo.dt);
    return momentForce;
}
pub fn update(self: *Player, frameInfo: *const FrameInfo) void {
    const momentForce = getForceActingOnPlayer(frameInfo);
    self.velocity = r.Vector2Add(self.velocity, momentForce);
    defer self.velocity = .{ .x = 0, .y = 0 };
    self.position = r.Vector2Add(self.position, self.velocity);
    self.activeAnimation = self.getAnimation(frameInfo.moveDirection);
    self.activeAnimation.update(frameInfo.dt);
}

pub fn render(self: *const Player) void {
    self.activeAnimation.render(self.position);
}

pub fn init(resourceManager: *const ResourceManager) Player {
    return Player{ .position = r.Vector2{ .x = 0, .y = 0 }, .velocity = .{ .x = 0, .y = 0 }, .animation = getAllAnimations(resourceManager) };
}

fn getAllAnimations(resourceManager: *const ResourceManager) AnimationArray {
    return AnimationArray{
        Animation.init(&resourceManager.playerStandStill),
        Animation.init(&resourceManager.playerWalkDown),
        Animation.init(&resourceManager.playerWalkLeft),
        Animation.init(&resourceManager.playerWalkRight),
        Animation.init(&resourceManager.playerWalkUp),
    };
}

test "getMoveVectorReturnsDown" {
    const vector = comptime getMoveVector(MoveDirection.Down);
    const normalized = r.Vector2Normalize(vector);
    try t.expectEqual(DOWN, normalized);
}
test "getMoveVectorReturnsLeft" {
    const vector = comptime getMoveVector(MoveDirection.Left);
    const normalized = r.Vector2Normalize(vector);
    try t.expectEqual(LEFT, normalized);
}
test "getMoveVectorReturnsRight" {
    const vector = comptime getMoveVector(MoveDirection.Right);
    const normalized = r.Vector2Normalize(vector);
    try t.expectEqual(RIGHT, normalized);
}
test "getMoveVectorReturnsUp" {
    const vector = comptime getMoveVector(MoveDirection.Up);
    const normalized = r.Vector2Normalize(vector);
    try t.expectEqual(UP, normalized);
}
test "getMoveVectorReturnsZero" {
    const vector = comptime getMoveVector(MoveDirection.None);
    const normalized = r.Vector2Normalize(vector);
    try t.expectEqual(ZERO, normalized);
}
