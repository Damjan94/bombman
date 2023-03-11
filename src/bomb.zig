const BombSpriteResourceManager = @import("resource/bomb_sprite_resource_manager.zig");
const Animation = @import("animation.zig");

const ExplosionAnimation = struct { center: Animation, horizontal: Animation, vertical: Animation, up: Animation, down: Animation, left: Animation, right: Animation };

burningAnimation: Animation,
explosionAnimation: ExplosionAnimation,
burnTime: f32 = 0,

pub fn init(resourceManager: *const BombSpriteResourceManager) @This() {
    return .{ .burningAnimation = Animation.init(&resourceManager.bomb), .explosionAnimation = .{
        .center = Animation.init(&resourceManager.explosions.center),
        .horizontal = Animation.init(&resourceManager.explosions.horizontal),
        .vertical = Animation.init(&resourceManager.explosions.vertical),
        .up = Animation.init(&resourceManager.explosions.up),
        .down = Animation.init(&resourceManager.explosions.down),
        .left = Animation.init(&resourceManager.explosions.left),
        .right = Animation.init(&resourceManager.explosions.right),
    } };
}

const FUSE_TIME_MILIS = 5000;

pub fn update(self: *@This(), dt: f32) void {
    self.burnTime += dt;
    self.burningAnimation.update(dt);
}

pub fn render(self: *const @This()) void {
    self.burningAnimation.render(.{ .x = 50, .y = 50 });
}
