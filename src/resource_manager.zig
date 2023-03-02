const r = @import("raylib.zig");
const std = @import("std");
pub const ResourceManager = struct {
    playerWalkDown: [4]r.Texture2D,
    playerWalkLeft: [4]r.Texture2D,
    playerWalkRight: [4]r.Texture2D,
    playerWalkUp: [4]r.Texture2D,
    pub fn init() ResourceManager {
        return .{
            .playerWalkDown = loadPlayerAnimation("down"),
            .playerWalkLeft = loadPlayerAnimation("left"),
            .playerWalkRight = loadPlayerAnimation("right"),
            .playerWalkUp = loadPlayerAnimation("up"),
        };
    }
};

const ASSETS_PATH = "./assets/";
const SPRITES_PATH = ASSETS_PATH ++ "sprites/";

const playerBoxDown = r.Texture2D;
const playerBoxLeft = r.Texture2D;
const playerBoxRight = r.Texture2D;
const playerBoxUp = r.Texture2D;

fn loadPlayerAnimation(direction: []const u8) [4]r.Texture {
    var textures = [4]r.Texture2D{ std.mem.zeroes(r.Texture2D), std.mem.zeroes(r.Texture2D), std.mem.zeroes(r.Texture2D), std.mem.zeroes(r.Texture2D) };
    var path_buffer = std.mem.zeroes([128]u8);
    for (textures, 0..) |_, i| {
        const path = std.fmt.bufPrint(&path_buffer, "{s}player_{s}_walk{d}.png", .{ SPRITES_PATH, direction, i + 1 }) catch unreachable;
        textures[i] = loadTexture(path);
    }
    return textures;
}
fn loadTexture(path: []const u8) r.Texture {
    // _ = path;
    // return std.mem.zeroes(r.Texture2D);
    return r.LoadTexture(path.ptr);
}
