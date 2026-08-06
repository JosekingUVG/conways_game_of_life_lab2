const std = @import("std");
const fb = @import("framebuffer.zig");
const rl = @import("raylib");

/// ======================
/// Juego de la vida
/// ======================
///
pub const GameOfLife = struct {
    current: fb.Framebuffer,
    next: fb.Framebuffer,

    alive: rl.Color,
    dead: rl.Color,
    generation: u64,

    const WorkerContext = struct {
        game: *GameOfLife,
        first_row: i32,
        last_row: i32,
        color: rl.Color,
    };

    // Constructor
    pub fn init(
        width: i32,
        height: i32,
        alive: rl.Color,
        dead: rl.Color,
    ) GameOfLife {
        return GameOfLife{
            .current = fb.Framebuffer.init(width, height, dead),
            .next = fb.Framebuffer.init(width, height, dead),
            .alive = alive,
            .dead = dead,
            .generation = 0,
        };
    }

    // Definir una célula (pixel) viva en la posición (x, y)
    pub fn setAlive(
        self: *GameOfLife,
        x: i32,
        y: i32,
    ) void {
        self.setAliveWithColor(x, y, self.alive);
    }

    // Definir una célula viva con un color específico
    pub fn setAliveWithColor(
        self: *GameOfLife,
        x: i32,
        y: i32,
        color: rl.Color,
    ) void {
        self.current.drawPixel(
            fb.Vec2{
                .x = x,
                .y = y,
            },
            color,
        );
    }

    // Definir una célula (pixel) muerta en la posición (x, y)
    pub fn setDead(
        self: *GameOfLife,
        x: i32,
        y: i32,
    ) void {
        self.current.drawPixel(
            fb.Vec2{
                .x = x,
                .y = y,
            },
            self.dead,
        );
    }

    fn isSameColor(
        left: rl.Color,
        right: rl.Color,
    ) bool {
        return left.r == right.r and
            left.g == right.g and
            left.b == right.b and
            left.a == right.a;
    }

    // Obtener el estado de una célula (pixel)
    pub fn isAlive(
        self: *GameOfLife,
        x: i32,
        y: i32,
    ) bool {
        // Si está fuera del tablero, se considera muerta.
        if (x < 0 or y < 0)
            return false;

        if (x >= self.current.width or y >= self.current.height)
            return false;

        const color = self.current.getColor(
            fb.Vec2{
                .x = x,
                .y = y,
            },
        );

        return !GameOfLife.isSameColor(color, self.dead);
    }

    // Contar vecinos vivos
    pub fn countAliveNeighbors(
        self: *GameOfLife,
        x: i32,
        y: i32,
    ) u8 {
        var neighbors: u8 = 0;

        var dy: i32 = -1;
        while (dy <= 1) : (dy += 1) {
            var dx: i32 = -1;
            while (dx <= 1) : (dx += 1) {

                // No contar la célula actual
                if (dx == 0 and dy == 0)
                    continue;

                if (self.isAlive(x + dx, y + dy)) {
                    neighbors += 1;
                }
            }
        }

        return neighbors;
    }

    // Implementar las reglas del juego de la vida
    /// Procesa un rango de filas y escribe el resultado en el framebuffer 'next'
    fn processRows(
        self: *GameOfLife,
        first_row: i32,
        last_row: i32,
        color: rl.Color,
    ) void {
        var y = first_row;

        while (y < last_row) : (y += 1) {
            var x: i32 = 0;

            while (x < self.current.width) : (x += 1) {
                const alive = self.isAlive(x, y);
                const neighbors = self.countAliveNeighbors(x, y);

                if (alive) {
                    // Underpopulation
                    if (neighbors < 2) {
                        self.next.drawPixel(
                            fb.Vec2{ .x = x, .y = y },
                            self.dead,
                        );
                    }
                    // Survival
                    else if (neighbors == 2 or neighbors == 3) {
                        self.next.drawPixel(
                            fb.Vec2{ .x = x, .y = y },
                            self.alive,
                        );
                    }
                    // Overpopulation
                    else {
                        self.next.drawPixel(
                            fb.Vec2{ .x = x, .y = y },
                            self.dead,
                        );
                    }
                } else {
                    // Reproduction
                    if (neighbors == 3) {
                        self.next.drawPixel(
                            fb.Vec2{ .x = x, .y = y },
                            color,
                        );
                    } else {
                        self.next.drawPixel(
                            fb.Vec2{ .x = x, .y = y },
                            self.dead,
                        );
                    }
                }
            }
        }
    }

    fn worker(context: *WorkerContext) void {
        context.game.processRows(
            context.first_row,
            context.last_row,
            context.color,
        );
    }

    // Calcula una nueva generación con hilos
    pub fn updateParallel(self: *GameOfLife) !void {
        self.next.clear();

        const max_threads: usize = 4;
        const row_count: usize = @max(1, @as(usize, @intCast(self.current.height)));
        const thread_count: usize = @min(max_threads, row_count);

        var threads: [max_threads]std.Thread = undefined;
        var contexts: [max_threads]WorkerContext = undefined;

        var start_row: i32 = 0;
        var rows_left: i32 = self.current.height;

        for (0..thread_count) |index| {
            const rows_for_thread = @divTrunc(rows_left, @as(i32, @intCast(thread_count - index)));
            const end_row = start_row + rows_for_thread;

            const colors = [_]rl.Color{
                rl.Color.red,
                rl.Color.green,
                rl.Color.blue,
                rl.Color.yellow,
            };

            contexts[index] = WorkerContext{
                .game = self,
                .first_row = start_row,
                .last_row = end_row,
                .color = colors[index],
            };

            threads[index] = try std.Thread.spawn(.{}, worker, .{&contexts[index]});

            start_row = end_row;
            rows_left -= rows_for_thread;
        }

        for (0..thread_count) |index| {
            threads[index].join();
        }

        const tmp = self.current;
        self.current = self.next;
        self.next = tmp;

        self.generation += 1;
    }

    // Calcula una nueva generación de forma secuencial
    pub fn update(self: *GameOfLife) void {
        self.next.clear();

        self.processRows(
            0,
            self.current.height,
            self.alive,
        );

        const tmp = self.current;
        self.current = self.next;
        self.next = tmp;

        self.generation += 1;
    }
};
