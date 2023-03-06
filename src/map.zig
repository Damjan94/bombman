const r = @import("raylib");
const MapSpriteResourceManager = @import("resource/map_sprite_resource_manager.zig");
pub const Map = @This();

const ARENA_SIZE = 5;

const map = [ARENA_SIZE]*const [5:0]u8{ "wwwww", "w b w", "w b w", "w w w", "wwwww" };

texture: *const MapSpriteResourceManager.MapTexture,

pub fn init(resourceManager: *const MapSpriteResourceManager, mapStyle: u8) Map {
    return Map{ .texture = &(resourceManager.levelTextures[mapStyle]) };
}
const HEIGHT = 52;
const WIDTH = 50;

pub fn render(self: *const Map) void {
    for (map, 0..) |line, y| {
        for (line, 0..) |char, x| {
            const x_c = @intCast(c_int, x);
            const y_c = @intCast(c_int, y);
            r.DrawTexture(self.texture.floor, x_c * WIDTH, y_c * HEIGHT, r.RAYWHITE);
            switch (char) {
                'w' => r.DrawTexture(self.texture.wall, x_c * WIDTH, y_c * HEIGHT, r.RAYWHITE),
                'b' => r.DrawTexture(self.texture.block, x_c * WIDTH, y_c * HEIGHT, r.RAYWHITE),
                ' ' => continue, //r.DrawTexture(self.texture.floor, x_c * WIDTH, y_c * HEIGHT, r.RAYWHITE),
                else => unreachable,
            }
        }
    }
}
