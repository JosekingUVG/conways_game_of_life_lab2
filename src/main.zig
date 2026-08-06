const rl = @import("raylib");

const gl = @import("game_of_life.zig");
const patterns = @import("patterns.zig");
const std = @import("std");

pub fn main() !void {
    const screenWidth = 300;
    const screenHeight = 300;

    rl.initWindow(screenWidth, screenHeight, "Conway's Game of Life");
    defer rl.closeWindow();

    rl.setTargetFPS(10);

    var game = gl.GameOfLife.init(
        screenWidth,
        screenHeight,
        rl.Color.green,
        rl.Color.black,
    );
    defer {
        game.current.deinit();
        game.next.deinit();
    }

    // Patrón de prueba
    patterns.iceCreature(&game, 130, 120);
    //patterns.iceCreature(&game, 55, 120);
    //patterns.iceCreature(&game, 90, 120);
    //patterns.iceCreature(&game, 120, 120);
    //patterns.iceCreature(&game, 180, 120);
    //patterns.iceCreature(&game, 230, 120);
    //patterns.glider(&game, 20, 20);
    //patterns.lwss(&game, 30, 30);
    //patterns.gosperGun(&game, 33, 33);

    // Colocar muchos patrones toad en distintas posiciones
    var x2: i32 = 20;
    while (x2 <= 280) : (x2 += 20) {
        var y2: i32 = 20;
        while (y2 <= 100) : (y2 += 20) {
            patterns.toad(&game, x2, y2);
        }
    }

    var x: i32 = 20;
    while (x <= 280) : (x += 20) {
        var y: i32 = 180;
        while (y <= 280 and y >= 180) : (y += 20) {
            patterns.toad(&game, x, y);
        }
    }

    var frameCounter: u32 = 0;

    while (!rl.windowShouldClose()) {
        frameCounter += 1;

        if (frameCounter >= 8) {
            try game.updateParallel();
            frameCounter = 0;
        }

        try game.current.swap();

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);
        game.current.render();
    }
}
