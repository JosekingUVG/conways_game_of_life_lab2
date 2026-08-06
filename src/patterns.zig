const fb = @import("framebuffer.zig");
const rl = @import("raylib");
const gl = @import("game_of_life.zig");

/// ======================
/// Patrones de prueba
/// ======================
///
pub fn glider(game: *gl.GameOfLife, x: i32, y: i32) void {
    game.setAliveWithColor(x + 1, y, rl.Color.red);
    game.setAliveWithColor(x + 2, y + 1, rl.Color.red);
    game.setAliveWithColor(x, y + 2, rl.Color.red);
    game.setAliveWithColor(x + 1, y + 2, rl.Color.red);
    game.setAliveWithColor(x + 2, y + 2, rl.Color.red);
}

pub fn lwss(game: *gl.GameOfLife, x: i32, y: i32) void {
    game.setAliveWithColor(x + 1, y, rl.Color.green);
    game.setAliveWithColor(x + 4, y, rl.Color.green);
    game.setAliveWithColor(x, y + 1, rl.Color.green);
    game.setAliveWithColor(x + 4, y + 1, rl.Color.green);
    game.setAliveWithColor(x, y + 2, rl.Color.green);
    game.setAliveWithColor(x + 1, y + 2, rl.Color.green);
    game.setAliveWithColor(x + 2, y + 2, rl.Color.green);
    game.setAliveWithColor(x + 3, y + 2, rl.Color.green);
    game.setAliveWithColor(x + 4, y + 2, rl.Color.green);
}

pub fn gosperGun(game: *gl.GameOfLife, x: i32, y: i32) void {
    const cells = [_]fb.Vec2{
        .{ .x = 1, .y = 5 },  .{ .x = 2, .y = 5 },  .{ .x = 1, .y = 6 },  .{ .x = 2, .y = 6 },
        .{ .x = 11, .y = 5 }, .{ .x = 12, .y = 5 }, .{ .x = 11, .y = 6 }, .{ .x = 10, .y = 6 },
        .{ .x = 10, .y = 7 }, .{ .x = 13, .y = 7 }, .{ .x = 14, .y = 7 }, .{ .x = 13, .y = 8 },
        .{ .x = 14, .y = 8 }, .{ .x = 15, .y = 8 }, .{ .x = 20, .y = 5 }, .{ .x = 21, .y = 5 },
        .{ .x = 20, .y = 6 }, .{ .x = 21, .y = 6 }, .{ .x = 20, .y = 7 }, .{ .x = 21, .y = 7 },
    };

    for (cells) |cell| {
        game.setAliveWithColor(x + cell.x, y + cell.y, rl.Color.blue);
    }
}

pub fn puffer(game: *gl.GameOfLife, x: i32, y: i32) void {
    const cells = [_]fb.Vec2{
        .{ .x = 1, .y = 0 }, .{ .x = 2, .y = 0 }, .{ .x = 3, .y = 0 },
        .{ .x = 0, .y = 1 }, .{ .x = 3, .y = 1 }, .{ .x = 0, .y = 2 },
        .{ .x = 3, .y = 2 }, .{ .x = 1, .y = 3 }, .{ .x = 2, .y = 3 },
        .{ .x = 3, .y = 3 },
    };

    for (cells) |cell| {
        game.setAliveWithColor(x + cell.x, y + cell.y, rl.Color.yellow);
    }
}

pub fn blinker(game: *gl.GameOfLife, x: i32, y: i32) void {
    game.setAliveWithColor(x, y, rl.Color.red);
    game.setAliveWithColor(x + 1, y, rl.Color.red);
    game.setAliveWithColor(x + 2, y, rl.Color.red);
}

pub fn toad(game: *gl.GameOfLife, x: i32, y: i32) void {
    game.setAliveWithColor(x + 1, y, rl.Color.magenta);
    game.setAliveWithColor(x + 2, y, rl.Color.magenta);
    game.setAliveWithColor(x + 3, y, rl.Color.magenta);
    game.setAliveWithColor(x, y + 1, rl.Color.magenta);
    game.setAliveWithColor(x + 3, y + 1, rl.Color.magenta);
    game.setAliveWithColor(x + 1, y + 2, rl.Color.magenta);
    game.setAliveWithColor(x + 2, y + 2, rl.Color.magenta);
    game.setAliveWithColor(x + 3, y + 2, rl.Color.magenta);
}

/// ======================
/// Patrón basado en coordenadas
/// ======================
///
pub fn iceCreature(game: *gl.GameOfLife, x: i32, y: i32) void {
    // Tallo (verde)
    var py: i32 = 12;
    while (py <= 21) : (py += 1) {
        game.setAliveWithColor(x + 10, y + py, rl.Color.green);
    }

    // Hojas de la base (verde / verde oscuro)
    var leaf_y: i32 = 14;
    while (leaf_y <= 21) : (leaf_y += 1) {
        var leaf_x: i32 = 3;
        while (leaf_x <= 18) : (leaf_x += 1) {
            game.setAliveWithColor(x + leaf_x, y + leaf_y, rl.Color.lime);
        }
    }

    // Cabeza principal (azul / celeste)
    var head_y: i32 = 2;
    while (head_y <= 10) : (head_y += 1) {
        var head_x: i32 = 6;
        while (head_x <= 15) : (head_x += 1) {
            game.setAliveWithColor(x + head_x, y + head_y, rl.Color.blue);
        }
    }

    // Hojas / picos de hielo traseros
    var back_y: i32 = 2;
    while (back_y <= 10) : (back_y += 1) {
        var back_x: i32 = 2;
        while (back_x <= 6) : (back_x += 1) {
            game.setAliveWithColor(x + back_x, y + back_y, rl.Color.white);
        }
    }

    // Boca / cañón
    var mouth_y: i32 = 3;
    while (mouth_y <= 9) : (mouth_y += 1) {
        var mouth_x: i32 = 16;
        while (mouth_x <= 21) : (mouth_x += 1) {
            game.setAliveWithColor(x + mouth_x, y + mouth_y, rl.Color.yellow);
        }
    }

    // Ojo
    game.setAliveWithColor(x + 12, y + 5, rl.Color.black);
    game.setAliveWithColor(x + 12, y + 6, rl.Color.black);
    game.setAliveWithColor(x + 12, y + 4, rl.Color.white);
    game.setAliveWithColor(x + 11, y + 4, rl.Color.white);
}
