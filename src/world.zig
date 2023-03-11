const Map = @import("map.zig");
const Player = @import("player.zig");
const std = @import("std");
map: Map,
players: std.ArrayList(Player),

pub fn render(self: *const @This()) void {
    self.map.render();
    for (self.players.items) |player| {
        player.render();
    }
}

pub fn update(self: *@This(), dt: f32) void {
    self.map.update(dt);
    for (self.players.items) |player| {
        player.update(dt);
    }
}
