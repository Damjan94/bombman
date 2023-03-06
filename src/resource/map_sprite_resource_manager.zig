const r = @import("raylib");
const ResourceManager = @import("resource_manager.zig");
pub const MapSpriteResourceManager = @This();

pub const MapTexture = struct { floor: r.Texture2D, wall: r.Texture2D, block: r.Texture2D };
const MapTextures = [7]MapTexture;
levelTextures: MapTextures,

pub fn init() MapSpriteResourceManager {
    return .{ .levelTextures = .{
        loadMapTexture(1),
        loadMapTexture(2),
        loadMapTexture(3),
        loadMapTexture(4),
        loadMapTexture(5),
        loadMapTexture(6),
        loadMapTexture(7),
    } };
}

fn loadMapTexture(index: u8) MapTexture {
    return MapTexture{
        .floor = ResourceManager.loadSprite("tile_env{d}_floor.png", index),
        .wall = ResourceManager.loadSprite("tile_env{d}_wall.png", index),
        .block = ResourceManager.loadSprite("tile_env{d}_block.png", index),
    };
}
