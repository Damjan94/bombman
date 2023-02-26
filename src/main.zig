const std = @import("std");
const r = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
});
pub fn main() !void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    r.InitWindow(screenWidth, screenHeight, "raylib [core] example - keyboard input");

    var ballPosition: r.Vector2 = .{ .x = screenWidth / 2, .y = screenHeight / 2 };

    r.SetTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!r.WindowShouldClose()) // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (r.IsKeyDown(r.KEY_RIGHT)) ballPosition.x += 2.0;
        if (r.IsKeyDown(r.KEY_LEFT)) ballPosition.x -= 2.0;
        if (r.IsKeyDown(r.KEY_UP)) ballPosition.y -= 2.0;
        if (r.IsKeyDown(r.KEY_DOWN)) ballPosition.y += 2.0;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        r.BeginDrawing();

        r.ClearBackground(r.RAYWHITE);

        r.DrawText("move the ball with arrow keys", 10, 10, 20, r.DARKGRAY);

        r.DrawCircleV(ballPosition, 50, r.MAROON);

        r.EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    r.CloseWindow(); // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
