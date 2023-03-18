const std = @import("std");
const t = std.testing;
const r = @import("raylib");
const Animation = @import("animation");
const Player = @This();

const DropBomb = fn (r.Vector2) void;
const DecideAction = fn () Action;

pub const AnimationArray = [@typeInfo(MoveDirection).Enum.fields.len]Animation;
pub const MoveDirection = enum(u8) { None, Down, Left, Right, Up };
pub const Action = struct {
    moveDirection: MoveDirection,
    shouldDropBomb: bool,
};
position: r.Vector2,
velocity: r.Vector2,
animation: AnimationArray,
activeAnimation: *Animation = undefined,
dropBomb: *const DropBomb,
decideAction: *const DecideAction,

const MOVE_SPEED = 100;

const ZERO = r.Vector2{ .x = 0, .y = 0 };
const DOWN = r.Vector2{ .x = 0, .y = 1 };
const LEFT = r.Vector2{ .x = -1, .y = 0 };
const RIGHT = r.Vector2{ .x = 1, .y = 0 };
const UP = r.Vector2{ .x = 0, .y = -1 };
pub fn init(animations: AnimationArray, dropBomb: *const DropBomb, decideAction: *const DecideAction) Player {
    return Player{ .position = r.Vector2{ .x = 0, .y = 0 }, .velocity = .{ .x = 0, .y = 0 }, .animation = animations, .dropBomb = dropBomb, .decideAction = decideAction };
}

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
pub fn update(self: *Player, dt: f32) void {
    const action = self.decideAction();

    self.handleMovement(action.moveDirection, dt);
    self.updateAnimation(action.moveDirection, dt);
    if (action.shouldDropBomb) {
        self.dropBomb(self.position);
    }
}

fn handleMovement(self: *@This(), moveDirection: MoveDirection, dt: f32) void {
    defer self.velocity = .{ .x = 0, .y = 0 };
    const force = getMovementVelocity(moveDirection, dt);
    self.addForce(force);
    self.applyVelocity();
}

fn getMovementVelocity(moveDirection: MoveDirection, dt: f32) r.Vector2 {
    const vector = getMoveVector(moveDirection);
    const force = r.Vector2Scale(vector, MOVE_SPEED);
    const momentForce = r.Vector2Scale(force, dt);
    return momentForce;
}

fn addForce(self: *@This(), force: r.Vector2) void {
    self.velocity = r.Vector2Add(self.velocity, force);
}
fn applyVelocity(self: *@This()) void {
    self.position = r.Vector2Add(self.position, self.velocity);
}

pub fn render(self: *const Player) void {
    self.activeAnimation.render(self.position);
}

fn updateAnimation(self: *@This(), moveDirection: MoveDirection, dt: f32) void {
    self.activeAnimation = self.getAnimation(moveDirection);
    self.activeAnimation.update(dt);
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
