const r = @import("raylib");
const std = @import("std");
const ResourceManager = @import("resource/explosion_resource_manager.zig");
const SPRITE_WIDTH = 49;
const SPRITE_HEIGHT = 44;

const EXPLOSION_ANIMATION_TIME = 0.2;
const DEFAULT_EXPLOSION_SIZE = 2;
const EXPLOSION_TIME = 1.5;

pub fn startExplosion(self: *@This(), position: r.Vector2) void {
    self.addCapacity(5) catch unreachable;
    const dummySide = ExpansionSide.Up;
    self.addExplosion(position, ResourceManager.Index.Center, 0, dummySide);

    self.addExplosion(.{ .x = position.x, .y = position.y - SPRITE_HEIGHT }, ResourceManager.Index.Up, DEFAULT_EXPLOSION_SIZE, ExpansionSide.Up);
    self.addExplosion(.{ .x = position.x, .y = position.y + SPRITE_HEIGHT }, ResourceManager.Index.Down, DEFAULT_EXPLOSION_SIZE, ExpansionSide.Down);
    self.addExplosion(.{ .x = position.x - SPRITE_WIDTH, .y = position.y }, ResourceManager.Index.Left, DEFAULT_EXPLOSION_SIZE, ExpansionSide.Left);
    self.addExplosion(.{ .x = position.x + SPRITE_WIDTH, .y = position.y }, ResourceManager.Index.Right, DEFAULT_EXPLOSION_SIZE, ExpansionSide.Right);
}

fn addCapacity(self: *@This(), count: usize) !void {
    try self.positions.ensureUnusedCapacity(count);
    try self.burnTimes.ensureUnusedCapacity(count);
    try self.sprites.ensureUnusedCapacity(count);
    try self.expansionsLeft.ensureUnusedCapacity(count);
    try self.expansionsSide.ensureUnusedCapacity(count);
}

const ExpansionSide = enum { Up, Down, Left, Right };

const Positions = std.ArrayList(r.Vector2);
const BurnTimes = std.ArrayList(f32);
const Sprites = std.ArrayList(ResourceManager.Index);
const ExpansionsLeft = std.ArrayList(u8);
const ExpnasionsSide = std.ArrayList(ExpansionSide);

resourceManager: *const ResourceManager,

explosionSpriteTimeout: f32 = EXPLOSION_ANIMATION_TIME,
explosionSpriteIndex: u1 = 0,

positions: Positions,
burnTimes: BurnTimes,
sprites: Sprites,
expansionsLeft: ExpansionsLeft,
expansionsSide: ExpnasionsSide,

pub fn init(allocator: std.mem.Allocator, resourceManager: *const ResourceManager) @This() {
    return .{
        .resourceManager = resourceManager,
        .positions = Positions.init(allocator),
        .burnTimes = BurnTimes.init(allocator),
        .sprites = Sprites.init(allocator),
        .expansionsLeft = ExpansionsLeft.init(allocator),
        .expansionsSide = ExpnasionsSide.init(allocator),
    };
}

pub fn deinit(self: *@This()) void {
    self.positions.deinit();
    self.burnTimes.deinit();
    self.sprites.deinit();
    self.expansionsLeft.deinit();
    self.expansionsSide.deinit();
}
pub fn update(self: *@This(), dt: f32, _: std.mem.Allocator) void {
    self.explosionSpriteTimeout -= dt;
    if (self.explosionSpriteTimeout < 0) {
        self.explosionSpriteIndex +%= 1;
        self.explosionSpriteTimeout = EXPLOSION_ANIMATION_TIME;
    }
    updateBurnTimes(self.burnTimes.items, dt);
    self.removeExpiredExplosions();
    self.growExplosions();
}

fn updateBurnTimes(burnTimes: []f32, dt: f32) void {
    for (0..burnTimes.len) |i| {
        burnTimes[i] -= dt;
    }
}
fn growExplosions(self: *@This()) void {
    const capacityToAdd = explosionExpansionCount(self.expansionsLeft.items);
    self.addCapacity(capacityToAdd) catch unreachable;

    for (self.positions.items, self.sprites.items, self.expansionsLeft.items, self.expansionsSide.items) |position, *sprite, *expansionsLeft, expansionSide| {
        if (expansionsLeft.* == 0) {
            continue;
        }
        const newPosition = getPositionToGrowTo(position, expansionSide);
        const newSprite = getGrowingSprite(expansionSide);
        const newExpansionsLeft = expansionsLeft.* - 1;
        self.addExplosion(newPosition, newSprite, newExpansionsLeft, expansionSide);

        expansionsLeft.* = 0;
        sprite.* = getSprite(expansionSide);
    }
}

fn explosionExpansionCount(expansionsCounts: []const u8) u16 {
    var count: u16 = 0;
    for (expansionsCounts) |expansionCount| {
        if (expansionCount > 0) {
            count += 1;
        }
    }
    return count;
}

fn getPositionToGrowTo(currentPosition: r.Vector2, expansionSide: ExpansionSide) r.Vector2 {
    var newPosition = currentPosition;
    switch (expansionSide) {
        ExpansionSide.Left => {
            newPosition.x -= SPRITE_WIDTH;
        },
        ExpansionSide.Right => {
            newPosition.x += SPRITE_WIDTH;
        },

        ExpansionSide.Up => {
            newPosition.y -= SPRITE_HEIGHT;
        },

        ExpansionSide.Down => {
            newPosition.y += SPRITE_HEIGHT;
        },
    }
    return newPosition;
}

fn getGrowingSprite(expansionSide: ExpansionSide) ResourceManager.Index {
    switch (expansionSide) {
        ExpansionSide.Left => {
            return ResourceManager.Index.Left;
        },
        ExpansionSide.Right => {
            return ResourceManager.Index.Right;
        },

        ExpansionSide.Up => {
            return ResourceManager.Index.Up;
        },

        ExpansionSide.Down => {
            return ResourceManager.Index.Down;
        },
    }
}

fn getSprite(expansionSide: ExpansionSide) ResourceManager.Index {
    switch (expansionSide) {
        ExpansionSide.Left, ExpansionSide.Right => {
            return ResourceManager.Index.Horizontal;
        },

        ExpansionSide.Up, ExpansionSide.Down => {
            return ResourceManager.Index.Vertical;
        },
    }
}

fn getExplosionToRemoveIndexes(allocator: std.mem.Allocator, burnTimes: []const f32) std.ArrayList(usize) {
    var indexes = std.ArrayList(usize).initCapacity(allocator, burnTimes.len) catch unreachable;
    for (burnTimes, 0..) |burnTime, i| {
        if (burnTime < 0) {
            indexes.appendAssumeCapacity(i);
        }
    }
    std.sort.sort(usize, indexes.items, {}, std.sort.desc(usize));
    return indexes;
}

fn addExplosion(self: *@This(), position: r.Vector2, sprite: ResourceManager.Index, expansionsLeft: u8, expansionSide: ExpansionSide) void {
    self.positions.appendAssumeCapacity(position);
    self.burnTimes.appendAssumeCapacity(EXPLOSION_TIME);
    self.sprites.appendAssumeCapacity(sprite);
    self.expansionsLeft.appendAssumeCapacity(expansionsLeft);
    self.expansionsSide.appendAssumeCapacity(expansionSide);
}
fn removeExplosion(self: *@This(), i: usize) void {
    _ = self.positions.swapRemove(i);
    _ = self.burnTimes.swapRemove(i);
    _ = self.sprites.swapRemove(i);
    _ = self.expansionsLeft.swapRemove(i);
    _ = self.expansionsSide.swapRemove(i);
}

fn removeExpiredExplosions(self: *@This()) void {
    if (self.positions.items.len == 0) {
        return;
    }
    var i = self.positions.items.len - 1;
    while (i > 0) : (i -= 1) {
        if (self.burnTimes.items[i] < 0) {
            self.removeExplosion(i);
        }
    }
    if (self.burnTimes.items[i] < 0) {
        self.removeExplosion(i);
    }
}

pub fn render(self: @This()) void {
    for (self.positions.items, self.sprites.items) |position, spriteIndex| {
        r.DrawTextureV(self.resourceManager.textures[@enumToInt(spriteIndex)][self.explosionSpriteIndex], position, r.RAYWHITE);
    }
}

test "startExplosion" {
    var explosions = init(std.testing.allocator, &std.mem.zeroes(ResourceManager));
    defer explosions.deinit();
    explosions.startExplosion(.{ .x = 0, .y = 0 });
    try std.testing.expectEqual(explosions.positions.items.len, 5);
}

const FRAME_STEP = 0.1;
test "updateBurnTimes" {
    var explosions = init(std.testing.allocator, &std.mem.zeroes(ResourceManager));
    defer explosions.deinit();
    explosions.startExplosion(.{ .x = 0, .y = 0 });
    updateBurnTimes(explosions.burnTimes.items, FRAME_STEP);
    try std.testing.expectEqual(explosions.burnTimes.items[0], EXPLOSION_TIME - FRAME_STEP);
}

test "growExplosion" {
    var explosions = init(std.testing.allocator, &std.mem.zeroes(ResourceManager));
    defer explosions.deinit();
    explosions.startExplosion(.{ .x = 0, .y = 0 });
    explosions.growExplosions();
    try std.testing.expectEqual(explosions.positions.items.len, 9);
}

test "getPositionToGrowToUp" {
    const position = r.Vector2{ .x = 0, .y = 0 };
    const expectedPosition = r.Vector2{ .x = position.x, .y = position.y - SPRITE_HEIGHT };
    const actual = getPositionToGrowTo(position, ExpansionSide.Up);
    try std.testing.expectEqual(expectedPosition, actual);
}
test "getPositionToGrowToDown" {
    const position = r.Vector2{ .x = 0, .y = 0 };
    const expectedPosition = r.Vector2{ .x = position.x, .y = position.y + SPRITE_HEIGHT };
    const actual = getPositionToGrowTo(position, ExpansionSide.Down);
    try std.testing.expectEqual(expectedPosition, actual);
}
test "getPositionToGrowToLeft" {
    const position = r.Vector2{ .x = 0, .y = 0 };
    const expectedPosition = r.Vector2{ .x = position.x - SPRITE_WIDTH, .y = position.y };
    const actual = getPositionToGrowTo(position, ExpansionSide.Left);
    try std.testing.expectEqual(expectedPosition, actual);
}
test "getPositionToGrowToRight" {
    const position = r.Vector2{ .x = 0, .y = 0 };
    const expectedPosition = r.Vector2{ .x = position.x + SPRITE_WIDTH, .y = position.y };
    const actual = getPositionToGrowTo(position, ExpansionSide.Right);
    try std.testing.expectEqual(expectedPosition, actual);
}

test "getExplosionsToRemoveIndexes" {
    const explosionTimes = [_]f32{ 5, 2, 0, -1, -0.3, 2, -5 };
    const expiredExplosions = getExplosionToRemoveIndexes(std.testing.allocator, &explosionTimes);
    defer expiredExplosions.deinit();
    try std.testing.expectEqual(expiredExplosions.items.len, 3);
    // ensure the order is reversed
    try std.testing.expectEqual(expiredExplosions.items[0], 6);
    try std.testing.expectEqual(expiredExplosions.items[1], 4);
    try std.testing.expectEqual(expiredExplosions.items[2], 3);
}

test "explosionExpansionCount" {
    const explosionExpansions = [_]u8{ 1, 2, 3, 0, 0, 4, 5, 0, 6 };
    const count = explosionExpansionCount(&explosionExpansions);
    try std.testing.expectEqual(count, 6);
}

test "removeExplosion" {
    var explosions = init(std.testing.allocator, &std.mem.zeroes(ResourceManager));
    defer explosions.deinit();
    try explosions.addCapacity(2);
    explosions.addExplosion(.{ .x = 0, .y = 0 }, ResourceManager.Index.Up, 0, ExpansionSide.Up);
    explosions.addExplosion(.{ .x = 1, .y = 1 }, ResourceManager.Index.Up, 0, ExpansionSide.Up);
    explosions.removeExplosion(0);
    try std.testing.expectEqual(explosions.positions.items[0], r.Vector2{ .x = 1, .y = 1 });
}

test "removeExpiredExplosion" {
    var explosions = init(std.testing.allocator, &std.mem.zeroes(ResourceManager));
    defer explosions.deinit();
    explosions.startExplosion(.{ .x = 0, .y = 0 });
    updateBurnTimes(explosions.burnTimes.items, EXPLOSION_TIME + 0.01);
    explosions.removeExpiredExplosions();
    try std.testing.expectEqual(explosions.burnTimes.items.len, 0);
}
test "removeExpiredExplosionNoItems" {
    var explosions = init(std.testing.allocator, &std.mem.zeroes(ResourceManager));
    defer explosions.deinit();
    updateBurnTimes(explosions.burnTimes.items, EXPLOSION_TIME + 0.01);
    explosions.removeExpiredExplosions();
    try std.testing.expectEqual(explosions.burnTimes.items.len, 0);
}
