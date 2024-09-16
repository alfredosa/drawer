const ray = @cImport({
    @cInclude("raylib.h");
});

pub const ShapeType = enum {
    Rectangle,
    Circle,
    Triangle,
    None,
};

pub const Shapes = struct {
    type: ShapeType,
    selecting_type: bool,
    color: ray.Color,
    start_pos: ray.Vector2,
    current_pos: ray.Vector2,
    select_pos: ray.Vector2,
    measuring: bool,

    pub fn init() !Shapes {
        return Shapes{
            .type = .None,
            .selecting_type = false,
            .measuring = false,
            .color = ray.YELLOW,
            .start_pos = .{ .x = 0, .y = 0 },
            .current_pos = .{ .x = 0, .y = 0 },
            .select_pos = .{ .x = 0, .y = 0 },
        };
    }

    fn draw_select(self: *const Shapes) void {
        const mouse_pos = self.select_pos;
        const dropdown_width: f32 = 120;
        const dropdown_height: f32 = 30;
        const spacing: f32 = 10;

        // Shape dropdown
        ray.DrawRectangle(@as(c_int, @intFromFloat(mouse_pos.x)), @as(c_int, @intFromFloat(mouse_pos.y + spacing)), @as(c_int, @intFromFloat(dropdown_width)), @as(c_int, @intFromFloat(dropdown_height)), ray.LIGHTGRAY);
        ray.DrawText("Shapes", @as(c_int, @intFromFloat(mouse_pos.x + 5)), @as(c_int, @intFromFloat(mouse_pos.y + spacing + 5)), 20, ray.BLACK);

        // Color dropdown
        ray.DrawRectangle(@as(c_int, @intFromFloat(mouse_pos.x)), @as(c_int, @intFromFloat(mouse_pos.y + dropdown_height + spacing * 2)), @as(c_int, @intFromFloat(dropdown_width)), @as(c_int, @intFromFloat(dropdown_height)), ray.LIGHTGRAY);
        ray.DrawText("Colors", @as(c_int, @intFromFloat(mouse_pos.x + 5)), @as(c_int, @intFromFloat(mouse_pos.y + dropdown_height + spacing * 2 + 5)), 20, ray.BLACK);
    }

    pub fn draw_measuring(self: *const Shapes) void {
        if (self.measuring != true) {
            return;
        }
    }

    pub fn start_selecting(self: *Shapes) void {
        self.selecting_type = true;
        self.select_pos = ray.GetMousePosition();
    }

    pub fn draw(self: *const Shapes) void {
        switch (self.selecting_type) {
            true => self.draw_select(),
            false => self.draw_measuring(),
        }
    }

    pub fn update() void {}
};
