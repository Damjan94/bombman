const r = @import("raylib");
const ResourceManager = @import("resource");
const Explosion = [2]r.Texture2D;

pub const Index = enum(u8) { Center = 0, Down = 1, Horizontal = 2, Left = 3, Right = 4, Up = 5, Vertical = 6 };

textures: [@typeInfo(Index).Enum.fields.len]Explosion,
pub fn init() @This() {
    return .{
        .textures = .{
            loadExplosion(""),
            loadExplosion("_down"),
            loadExplosion("_horizontal"),
            loadExplosion("_left"),
            loadExplosion("_right"),
            loadExplosion("_up"),
            loadExplosion("_vertical"),
        },
    };
}

fn loadExplosion(comptime name: []const u8) Explosion {
    return .{
        ResourceManager.loadSprite("flame{d}" ++ name ++ ".png", 1),
        ResourceManager.loadSprite("flame{d}" ++ name ++ ".png", 2),
    };
}
