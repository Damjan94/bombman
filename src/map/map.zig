const r = @import("raylib");
const std = @import("std");
const MapSpriteResourceManager = @import("resource/map_sprite_resource_manager.zig");
pub const Map = @This();
pub const MapSize = 5;

texture: *const MapSpriteResourceManager.MapTexture,
entities: std.ArrayList(Entity),
pub fn init(allocator: std.mem.Allocator, texture: *const MapSpriteResourceManager.MapTexture, map: *const [MapSize]*const [MapSize:0]u8) Map {
    return Map{ .texture = texture, .entities = createEntities(allocator, map) };
}
const HEIGHT = 45;
const WIDTH = 50;

fn createEntities(allocator: std.mem.Allocator, map: *const [5]*const [5:0]u8) std.ArrayList(Entity) {
    var entities = std.ArrayList(Entity).init(allocator);
    for (map, 0..) |line, y| {
        for (line, 0..) |char, x| {
            switch (char) {
                'w' => entities.append(.{ .position = .{ .x = @intToFloat(f32, x * WIDTH), .y = @intToFloat(f32, y * HEIGHT) }, .entityType = EntityType.wall }) catch unreachable,
                'b' => entities.append(.{ .position = .{ .x = @intToFloat(f32, x * WIDTH), .y = @intToFloat(f32, y * HEIGHT) }, .entityType = EntityType.block }) catch unreachable,
                ' ' => continue,
                else => unreachable,
            }
        }
    }
    return entities;
}

const Entity = struct { position: r.Vector2, entityType: EntityType };
const EntityType = enum { wall, block };

pub fn update(self: *@This(), dt: f32) void {
    _ = self;
    _ = dt;
}

pub fn render(self: *const Map) void {
    for (0..MapSize) |y| {
        for (0..MapSize) |x| {
            r.DrawTexture(self.texture.floor, @intCast(c_int, x * WIDTH), @intCast(c_int, y * HEIGHT), r.RAYWHITE);
        }
    }
    for (self.entities.items) |entity| {
        switch (entity.entityType) {
            EntityType.wall => r.DrawTextureV(self.texture.wall, entity.position, r.RAYWHITE),
            EntityType.block => r.DrawTextureV(self.texture.block, entity.position, r.RAYWHITE),
        }
    }
}
