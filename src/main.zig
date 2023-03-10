const std = @import("std");
const r = @import("raylib");
const Map = @import("map.zig");
const Player = @import("player.zig");
const FrameInfo = @import("frame_info.zig");
const Bomb = @import("bomb.zig");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ResourceManager = @import("resource/resource_manager.zig");

const mapLayout = [_]*const [5:0]u8{ "wwwww", "w   w", "w   w", "w b w", "wwwww" };

pub fn main() !void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    r.InitWindow(screenWidth, screenHeight, "raylib [core] example - keyboard input");

    const resourceManager = ResourceManager.init();
    var player = Player.init(&resourceManager.playerSprites);
    var map = Map.init(gpa.allocator(), &(resourceManager.mapSprites.levelTextures[2]), &mapLayout);
    var bomb = Bomb.init(&(resourceManager.bombSprites));
    r.SetTargetFPS(60); // Set our game to run at 60 frames-per-second
    // Main game loop
    while (!r.WindowShouldClose()) // Detect window close button or ESC key
    {
        const dt = r.GetFrameTime();
        // Update
        //----------------------------------------------------------------------------------
        var moveDirection = Player.MoveDirection.None;
        if (r.IsKeyDown(r.KEY_RIGHT)) moveDirection = Player.MoveDirection.Right;
        if (r.IsKeyDown(r.KEY_LEFT)) moveDirection = Player.MoveDirection.Left;
        if (r.IsKeyDown(r.KEY_UP)) moveDirection = Player.MoveDirection.Up;
        if (r.IsKeyDown(r.KEY_DOWN)) moveDirection = Player.MoveDirection.Down;
        //----------------------------------------------------------------------------------
        map.update(dt);
        const playerFrameInfo = FrameInfo.init(dt, moveDirection);
        player.update(&playerFrameInfo);
        bomb.update(dt);
        // Draw
        //----------------------------------------------------------------------------------
        r.BeginDrawing();

        r.ClearBackground(r.RAYWHITE);
        r.DrawText("move the ball with arrow keys", 10, 10, 20, r.DARKGRAY);
        map.render();
        bomb.render();
        player.render();

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
