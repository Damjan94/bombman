const Animation = @import("animation");
const r = @import("raylib");
burningAnimation: Animation,
burnTime: f32 = 0,
position: r.Vector2,
pub fn init(position: r.Vector2, burningAnimation: Animation) @This() {
    return .{
        .position = position,
        .burningAnimation = burningAnimation,
    };
}

const FUSE_TIME_SECONDS = 5;

pub fn update(self: *@This(), dt: f32) void {
    self.burnTime += dt;
    self.burningAnimation.update(dt);
}

pub fn shouldExplode(self: *const @This()) bool {
    return self.burnTime > FUSE_TIME_SECONDS;
}

pub fn render(self: *const @This()) void {
    self.burningAnimation.render(self.position);
}
