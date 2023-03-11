const r = @import("raylib");
const std = @import("std");
const PlayerSpriteResourceManager = @import("player_sprite_resource_manager.zig");
const MapSpriteResourceManager = @import("map_sprite_resource_manager.zig");
const BombSpriteResourceManager = @import("bomb_sprite_resource_manager.zig");
pub const ResourceManager = @This();

playerSprites: PlayerSpriteResourceManager,
mapSprites: MapSpriteResourceManager,
bombSprites: BombSpriteResourceManager,

pub fn init() ResourceManager {
    return .{
        .playerSprites = PlayerSpriteResourceManager.init(),
        .mapSprites = MapSpriteResourceManager.init(),
        .bombSprites = BombSpriteResourceManager.init(),
    };
}

const ASSETS_PATH = "./assets/";
pub const SPRITES_PATH = ASSETS_PATH ++ "sprites/";

const ResourceManagerError = error{
    FailedToLoadTexture,
};

pub fn loadTexture(path: []const u8) !r.Texture {
    const zeroTexture = std.mem.zeroes(r.Texture2D);
    const texture = r.LoadTexture(path.ptr);
    if (std.meta.eql(texture, zeroTexture)) {
        return ResourceManagerError.FailedToLoadTexture;
    }
    return texture;
}

pub fn loadSprite(comptime formatString: []const u8, index: u8) r.Texture2D {
    const U8_MAX_CHARS = 3;
    var buffer = std.mem.zeroes([SPRITES_PATH.len + formatString.len + U8_MAX_CHARS]u8);
    const path = std.fmt.bufPrint(&buffer, SPRITES_PATH ++ formatString, .{index}) catch unreachable;

    return ResourceManager.loadTexture(path) catch std.debug.panic("Failed to load texture {s}\n", .{path});
}
