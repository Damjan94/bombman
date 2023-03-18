const std = @import("std");
const Bomb = @import("bomb.zig");
const BombFactory = @import("bomb_factory.zig");
const r = @import("raylib");
const StartExplosion = fn (r.Vector2) void;
const Bombs = std.ArrayList(Bomb);
bombs: Bombs,
bombFactory: BombFactory,
pub fn init(allocator: std.mem.Allocator, bombFactory: BombFactory) @This() {
    return .{
        .bombFactory = bombFactory,
        .bombs = Bombs.init(allocator),
    };
}
pub fn deinit(self: *@This()) void {
    self.bombs.deinit();
}
fn handleBomb(bombs: *Bombs, startExplosion: *const StartExplosion, i: usize, dt: f32) void {
    var bomb = &bombs.items.ptr[i];
    bomb.update(dt);
    if (bomb.shouldExplode()) {
        startExplosion(bomb.position);
        _ = bombs.swapRemove(i);
    }
}
pub fn update(self: *@This(), dt: f32, startExplosion: *const StartExplosion) void {
    if (self.bombs.items.len == 0) {
        return;
    }
    var i = self.bombs.items.len - 1;
    while (i != 0) : (i = i - 1) {
        handleBomb(&self.bombs, startExplosion, i, dt);
    }
    handleBomb(&self.bombs, startExplosion, 0, dt);
}

pub fn render(self: @This()) void {
    for (self.bombs.items) |bomb| {
        bomb.render();
    }
}

pub fn placeBomb(self: *@This(), position: r.Vector2) void {
    self.bombs.append(self.bombFactory.createBomb(position)) catch unreachable;
}
