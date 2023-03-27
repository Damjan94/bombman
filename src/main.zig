const std = @import("std");
const r = @import("raylib");
const Map = @import("map/map.zig");
const Player = @import("player/player.zig");
const Animation = @import("animation");
const BombFactory = @import("bomb/bomb_factory.zig");
const BombManager = @import("bomb/bomb_manager.zig");
const Bomb = @import("bomb/bomb.zig");
const Explosions = @import("explosion/explosion.zig");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

const BombSpriteResourceManager = @import("bomb/resource/bomb_sprite_resource_manager.zig");
const PlayerSpriteResourceManager = @import("player/resource/player_sprite_resource_manager.zig");
const MapSpriteResourceManager = @import("map/resource/map_sprite_resource_manager.zig");
const ExplosionResourceManager = @import("explosion/resource/explosion_resource_manager.zig");

const mapLayout = [_]*const [5:0]u8{ "wwwww", "w   w", "w   w", "w b w", "wwwww" };
fn startExplosion(position: r.Vector2) void {
    explosions.?.startExplosion(position);
}
var explosions: ?Explosions = null;
var bombManager: ?BombManager = null;
fn dropBomb(position: r.Vector2) void {
    bombManager.?.placeBomb(position);
}

fn decideMovement() Player.Action {
    var moveDirection = Player.MoveDirection.None;
    if (r.IsKeyDown(r.KEY_RIGHT)) moveDirection = Player.MoveDirection.Right;
    if (r.IsKeyDown(r.KEY_LEFT)) moveDirection = Player.MoveDirection.Left;
    if (r.IsKeyDown(r.KEY_UP)) moveDirection = Player.MoveDirection.Up;
    if (r.IsKeyDown(r.KEY_DOWN)) moveDirection = Player.MoveDirection.Down;
    return .{
        .moveDirection = moveDirection,
        .shouldDropBomb = r.IsKeyPressed(r.KEY_SPACE),
    };
}
fn createPlayerAnimations(resourceManager: *const PlayerSpriteResourceManager) Player.AnimationArray {
    return .{
        Animation.init(&resourceManager.playerStandStill),
        Animation.init(&resourceManager.playerWalkDown),
        Animation.init(&resourceManager.playerWalkLeft),
        Animation.init(&resourceManager.playerWalkRight),
        Animation.init(&resourceManager.playerWalkUp),
    };
}
pub fn main() !void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    r.InitWindow(screenWidth, screenHeight, "raylib [core] example - keyboard input");

    const bombSpriteResourceManager = BombSpriteResourceManager.init();
    const playerSpriteResourceManager = PlayerSpriteResourceManager.init();
    const mapSpriteResourceManager = MapSpriteResourceManager.init();
    const explosionResourceManager = ExplosionResourceManager.init();

    explosions = Explosions.init(gpa.allocator(), &explosionResourceManager);

    var player = Player.init(createPlayerAnimations(&playerSpriteResourceManager), dropBomb, decideMovement);
    var map = Map.init(gpa.allocator(), &(mapSpriteResourceManager.levelTextures[2]), &mapLayout);

    const bombFactory = BombFactory.init(&bombSpriteResourceManager);
    bombManager = BombManager.init(gpa.allocator(), bombFactory);
    defer bombManager.?.deinit();
    r.SetTargetFPS(60); // Set our game to run at 60 frames-per-second
    // Main game loop
    while (!r.WindowShouldClose()) // Detect window close button or ESC key
    {
        const dt = r.GetFrameTime();
        // Update
        //----------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------
        map.update(dt);
        player.update(dt);
        bombManager.?.update(dt, startExplosion);
        explosions.?.update(dt, gpa.allocator());
        // Draw
        //----------------------------------------------------------------------------------
        r.BeginDrawing();

        r.ClearBackground(r.RAYWHITE);
        r.DrawText("move the ball with arrow keys", 10, 10, 20, r.DARKGRAY);
        map.render();
        bombManager.?.render();
        player.render();
        explosions.?.render();

        r.EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    r.CloseWindow(); // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
test {
    std.testing.refAllDecls(@This());
}
