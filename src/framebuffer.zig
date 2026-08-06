const rl = @import("raylib");

/// ======================
/// Tipos geométricos
/// ======================
pub const Vec2 = struct {
    x: i32,
    y: i32,
};

pub const Polygon = struct {
    vertices: []const Vec2,
};

/// ======================
/// Framebuffer
/// ======================
pub const Framebuffer = struct {
    width: i32,
    height: i32,

    image: rl.Image,
    texture: ?rl.Texture,

    background_color: rl.Color,

    /// Constructor
    pub fn init(width: i32, height: i32, background: rl.Color) Framebuffer {
        return .{
            .width = width,
            .height = height,
            .image = rl.genImageColor(width, height, background),
            .texture = null,
            .background_color = background,
        };
    }

    /// Liberar memoria
    pub fn deinit(self: *Framebuffer) void {
        if (self.texture) |texture| {
            rl.unloadTexture(texture);
        }

        rl.unloadImage(self.image);
    }

    /// Borra completamente el framebuffer
    pub fn clear(self: *Framebuffer) void {
        self.image.clearBackground(self.background_color);

        if (self.texture) |texture| {
            rl.unloadTexture(texture);
        }

        self.texture = null;
    }

    /// Dibuja un único pixel
    pub fn drawPixel(
        self: *Framebuffer,
        point: Vec2,
        color: rl.Color,
    ) void {
        if (point.x < 0 or point.y < 0)
            return;

        if (point.x >= self.width or point.y >= self.height)
            return;

        self.image.drawPixel(
            point.x,
            point.y,
            color,
        );
    }

    // Obtener color de un pixel
    pub fn getColor(
        self: *Framebuffer,
        point: Vec2,
    ) rl.Color {
        return self.image.getColor(
            point.x,
            point.y,
        );
    }

    /// Dibuja una línea entre dos puntos
    pub fn drawLine(
        self: *Framebuffer,
        start: Vec2,
        end: Vec2,
        color: rl.Color,
    ) void {
        const dx: f32 = @floatFromInt(end.x - start.x);
        const dy: f32 = @floatFromInt(end.y - start.y);

        const absDx = @abs(dx);
        const absDy = @abs(dy);

        const steps: i32 = @intFromFloat(@max(absDx, absDy));

        // Caso especial:
        if (steps == 0) {
            self.drawPixel(start, color);
            return;
        }

        const xIncrement = dx / @as(f32, @floatFromInt(steps));
        const yIncrement = dy / @as(f32, @floatFromInt(steps));

        var x: f32 = @floatFromInt(start.x);
        var y: f32 = @floatFromInt(start.y);

        var i: i32 = 0;

        while (i <= steps) : (i += 1) {
            self.drawPixel(
                .{
                    .x = @intFromFloat(@round(x)),
                    .y = @intFromFloat(@round(y)),
                },
                color,
            );

            x += xIncrement;
            y += yIncrement;
        }
    }

    /// Dibuja únicamente el contorno del polígono
    pub fn drawPolygon(
        self: *Framebuffer,
        polygon: Polygon,
        color: rl.Color,
    ) void {
        if (polygon.vertices.len < 2)
            return;

        for (polygon.vertices, 0..) |current, i| {
            const next =
                polygon.vertices[(i + 1) % polygon.vertices.len];

            self.drawLine(
                current,
                next,
                color,
            );
        }
    }

    /// Convierte la imagen en textura
    pub fn swap(self: *Framebuffer) !void {
        if (self.texture) |texture| {
            rl.unloadTexture(texture);
        }

        self.texture =
            try rl.loadTextureFromImage(self.image);
    }

    /// Muestra el framebuffer en pantalla
    pub fn render(self: *Framebuffer) void {
        if (self.texture) |texture| {
            rl.drawTexture(
                texture,
                0,
                0,
                rl.Color.white,
            );
        }
    }

    /// Pintar el poligono por pixeles (relleno)
    pub fn fillPolygon(
        self: *Framebuffer,
        polygon: Polygon,
        color: rl.Color,
    ) void {
        if (polygon.vertices.len < 3)
            return;

        // ---------------------------------------
        // Encontrar el rango vertical
        // ---------------------------------------

        var minY = polygon.vertices[0].y;
        var maxY = polygon.vertices[0].y;

        for (polygon.vertices) |v| {
            if (v.y < minY) minY = v.y;
            if (v.y > maxY) maxY = v.y;
        }

        // Arreglo temporal para guardar las X
        var intersections: [128]i32 = undefined;

        var y = minY;

        while (y <= maxY) : (y += 1) {
            var count: usize = 0;

            // -----------------------------------
            // Buscar intersecciones
            // -----------------------------------

            for (polygon.vertices, 0..) |current, i| {
                const next =
                    polygon.vertices[(i + 1) % polygon.vertices.len];

                const y1 = current.y;
                const y2 = next.y;

                // Regla para evitar contar dos veces
                if (!((y >= @min(y1, y2)) and
                    (y < @max(y1, y2))))
                {
                    continue;
                }

                // Ignorar líneas horizontales
                if (y1 == y2)
                    continue;

                const t =
                    @as(f32, @floatFromInt(y - y1)) /
                    @as(f32, @floatFromInt(y2 - y1));

                const x =
                    @as(f32, @floatFromInt(current.x)) +
                    t *
                        @as(f32, @floatFromInt(next.x - current.x));

                intersections[count] =
                    @intFromFloat(@round(x));

                count += 1;
            }

            // -----------------------------------
            // Ordenar intersecciones
            // -----------------------------------

            var i: usize = 0;

            while (i < count) : (i += 1) {
                var j = i + 1;

                while (j < count) : (j += 1) {
                    if (intersections[j] < intersections[i]) {
                        const tmp = intersections[i];
                        intersections[i] = intersections[j];
                        intersections[j] = tmp;
                    }
                }
            }

            // -----------------------------------
            // Pintar entre pares
            // -----------------------------------

            var k: usize = 0;

            while (k + 1 < count) : (k += 2) {
                var x = intersections[k];

                while (x <= intersections[k + 1]) : (x += 1) {
                    self.drawPixel(
                        .{
                            .x = x,
                            .y = y,
                        },
                        color,
                    );
                }
            }
        }
    }
};
