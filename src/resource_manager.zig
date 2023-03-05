const r = @import("raylib.zig");
const std = @import("std");
pub const ResourceManager = @This();

playerStandStill: [1]r.Texture2D,
playerWalkDown: [3]r.Texture2D,
playerWalkLeft: [2]r.Texture2D,
playerWalkRight: [2]r.Texture2D,
playerWalkUp: [3]r.Texture2D,

pub fn init() ResourceManager {
    return .{
        .playerStandStill = .{loadTexture(SPRITES_PATH ++ "player_down.png") catch unreachable},
        .playerWalkDown = loadPlayerAnimationVertical("down"),
        .playerWalkLeft = loadPlayerAnimationHorizontal("left"),
        .playerWalkRight = loadPlayerAnimationHorizontal("right"),
        .playerWalkUp = loadPlayerAnimationVertical("up"),
    };
}

const ASSETS_PATH = "./assets/";
const SPRITES_PATH = ASSETS_PATH ++ "sprites/";

// const playerBoxDown = r.Texture2D;
// const playerBoxLeft = r.Texture2D;
// const playerBoxRight = r.Texture2D;
// const playerBoxUp = r.Texture2D;

fn loadPlayerAnimationVertical(direction: []const u8) [3]r.Texture {
    var textures = [3]r.Texture2D{
        loadPlayerWalkAnimation(direction, 1),
        loadPlayerWalkAnimation(direction, 2),
        loadPlayerWalkAnimation(direction, 3),
    };
    return textures;
}
fn loadPlayerAnimationHorizontal(direction: []const u8) [2]r.Texture {
    var textures = [2]r.Texture2D{
        loadPlayerWalkAnimation(direction, 1),
        loadPlayerWalkAnimation(direction, 3),
    };
    return textures;
}

fn loadPlayerWalkAnimation(direction: []const u8, index: u8) r.Texture {
    const STRING_FORMAT_BUFFER_SIZE = 64;
    const U8_MAX_CHARS = 3;
    const FORMAT_STRING = SPRITES_PATH ++ "player_{s}_walk{d}.png";
    const stringSize = FORMAT_STRING.len + direction.len + U8_MAX_CHARS;
    std.debug.assert(STRING_FORMAT_BUFFER_SIZE > stringSize);
    var buffer = std.mem.zeroes([STRING_FORMAT_BUFFER_SIZE]u8);
    const path = std.fmt.bufPrint(&buffer, FORMAT_STRING, .{ direction, index }) catch unreachable;

    return loadTexture(path) catch std.debug.panic("Failed to load texture {s}\n", .{path});
}
const ResourceManagerError = error{
    FailedToLoadTexture,
};

fn loadTexture(path: []const u8) !r.Texture {
    const zeroTexture = std.mem.zeroes(r.Texture2D);
    const texture = r.LoadTexture(path.ptr);
    if (std.meta.eql(texture, zeroTexture)) {
        return ResourceManagerError.FailedToLoadTexture;
    }
    return texture;
}
