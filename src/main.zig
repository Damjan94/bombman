const std = @import("std");
const r = @import("raylib.zig");
const player = @import("player.zig");
const Animation = @import("animation.zig");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ResourceManager = @import("resource_manager.zig");
pub fn main() !void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    r.InitWindow(screenWidth, screenHeight, "raylib [core] example - keyboard input");

    var ball: player.Player = .{ .position = .{ .x = screenWidth / 2, .y = screenHeight / 2 } };
    const resourceManager = ResourceManager.ResourceManager.init();
    r.SetTargetFPS(60); // Set our game to run at 60 frames-per-second
    var animation = Animation.init(&resourceManager.playerWalkDown);
    // Main game loop
    while (!r.WindowShouldClose()) // Detect window close button or ESC key
    {
        const dt = r.GetFrameTime();
        animation.update(dt);
        // Update
        //----------------------------------------------------------------------------------
        if (r.IsKeyDown(r.KEY_RIGHT)) ball.position.x += 2.0;
        if (r.IsKeyDown(r.KEY_LEFT)) ball.position.x -= 2.0;
        if (r.IsKeyDown(r.KEY_UP)) ball.position.y -= 2.0;
        if (r.IsKeyDown(r.KEY_DOWN)) ball.position.y += 2.0;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        r.BeginDrawing();

        r.ClearBackground(r.RAYWHITE);
        r.DrawText("move the ball with arrow keys", 10, 10, 20, r.DARKGRAY);

        animation.render(ball.position);

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
