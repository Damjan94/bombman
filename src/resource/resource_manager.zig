const r = @import("raylib");
const std = @import("std");
const PlayerSpriteResourceManager = @import("player_sprite_resource_manager.zig");
pub const ResourceManager = @This();

playerSprites: PlayerSpriteResourceManager,

pub fn init() ResourceManager {
    return .{
        .playerSprites = PlayerSpriteResourceManager.init(),
    };
}

const ASSETS_PATH = "./assets/";
pub const SPRITES_PATH = ASSETS_PATH ++ "sprites/";

// const playerBoxDown = r.Texture2D;
// const playerBoxLeft = r.Texture2D;
// const playerBoxRight = r.Texture2D;
// const playerBoxUp = r.Texture2D;

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
