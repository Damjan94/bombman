const FrameInfo = @This();
const Player = @import("player.zig");

dt: f32,
moveDirection: Player.MoveDirection,

pub fn init(dt: f32, moveDirection: Player.MoveDirection) FrameInfo {
    return .{ .dt = dt, .moveDirection = moveDirection };
}
