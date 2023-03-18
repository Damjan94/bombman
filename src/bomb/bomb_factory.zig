const r = @import("raylib");
const ResourceManager = @import("resource/bomb_sprite_resource_manager.zig");
const Bomb = @import("bomb.zig");
const Animation = @import("animation");

bombTemplate: Bomb,

pub fn init(resourceManager: *const ResourceManager) @This() {
    return .{ .bombTemplate = Bomb.init(r.Vector2Zero(), Animation.init(&resourceManager.bomb)) };
}

pub fn createBomb(self: @This(), position: r.Vector2) Bomb {
    var newBomb = self.bombTemplate;
    newBomb.position = position;
    return newBomb;
}
