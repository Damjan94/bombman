const ResourceManager = @import("resource");
const r = @import("raylib");

const BombTextures = [3]r.Texture2D;
const BombExplosionTextures = [2]r.Texture2D;
const BombExplosionDirections = struct { center: BombExplosionTextures, horizontal: BombExplosionTextures, vertical: BombExplosionTextures, up: BombExplosionTextures, down: BombExplosionTextures, left: BombExplosionTextures, right: BombExplosionTextures };
bomb: BombTextures,
explosions: BombExplosionDirections,

pub fn init() @This() {
    return .{
        .bomb = .{
            ResourceManager.loadSprite("bomb{d}.png", 1),
            ResourceManager.loadSprite("bomb{d}.png", 2),
            ResourceManager.loadSprite("bomb{d}.png", 3),
        },
        .explosions = .{
            .center = loadExplosion(""),
            .horizontal = loadExplosion("_horizontal"),
            .vertical = loadExplosion("_vertical"),
            .up = loadExplosion("_up"),
            .down = loadExplosion("_down"),
            .left = loadExplosion("_left"),
            .right = loadExplosion("_right"),
        },
    };
}

fn loadExplosion(comptime suffix: []const u8) BombExplosionTextures {
    return .{
        ResourceManager.loadSprite("flame{d}" ++ suffix ++ ".png", 1),
        ResourceManager.loadSprite("flame{d}" ++ suffix ++ ".png", 2),
    };
}
