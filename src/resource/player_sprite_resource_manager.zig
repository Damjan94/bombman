const std = @import("std");
const ResourceManager = @import("resource_manager.zig");
const r = @import("raylib");
pub const PlayerSpriteResourceManager = @This();
const PlayerStandStill = [1]r.Texture2D;
const PlayerWalkVertical = [3]r.Texture2D;
const PlayerWalkHorizontal = [2]r.Texture2D;

playerStandStill: PlayerStandStill,
playerWalkDown: PlayerWalkVertical,
playerWalkLeft: PlayerWalkHorizontal,
playerWalkRight: PlayerWalkHorizontal,
playerWalkUp: PlayerWalkVertical,

pub fn init() PlayerSpriteResourceManager {
    return .{
        .playerStandStill = .{ResourceManager.loadTexture(ResourceManager.SPRITES_PATH ++ "player_down.png") catch unreachable},
        .playerWalkDown = loadPlayerSpriteVertical("player_down_walk{d}.png"),
        .playerWalkLeft = loadPlayerSpriteHorizontal("player_left_walk{d}.png"),
        .playerWalkRight = loadPlayerSpriteHorizontal("player_right_walk{d}.png"),
        .playerWalkUp = loadPlayerSpriteVertical("player_up_walk{d}.png"),
    };
}
fn loadPlayerSpriteVertical(comptime formatString: []const u8) PlayerWalkVertical {
    var textures = [3]r.Texture2D{
        ResourceManager.loadSprite(formatString, 1),
        ResourceManager.loadSprite(formatString, 2),
        ResourceManager.loadSprite(formatString, 3),
    };
    return textures;
}
fn loadPlayerSpriteHorizontal(comptime formatString: []const u8) PlayerWalkHorizontal {
    var textures = [2]r.Texture2D{
        ResourceManager.loadSprite(formatString, 1),
        ResourceManager.loadSprite(formatString, 3),
    };
    return textures;
}
