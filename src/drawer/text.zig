const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

pub const TextBox = struct {
    coords: ray.Vector2,
    dims: ray.Vector2,

    pub fn draw(self: *const TextBox) void {
        ray.DrawRectangleLines(@as(i32, @intFromFloat(self.coords.x)), @as(i32, @intFromFloat(self.coords.y)), @as(i32, @intFromFloat(self.dims.x)), @as(i32, @intFromFloat(self.dims.y)), ray.BLACK);

        // Draw some placeholder text
        ray.DrawTextEx(ray.GetFontDefault(), "Text Box", .{ .x = self.coords.x + 10, .y = self.coords.y + 10 }, 20, 1, ray.BLACK);
    }
};

pub const Text = struct {
    font: ray.Font,
    placed: bool, // TODO: THIS IS A HACK

    pub fn init() !Text {
        const font = ray.LoadFont("assets/fonts/ubuntu.ttf");
        if (font.texture.id == 0) {
            return error.FontLoadFailed;
        }
        const placed = false;
        return Text{ .font = font, .placed = placed };
    }

    pub fn deinit(self: *Text) void {
        ray.UnloadFont(self.font);
    }

    pub fn previewTextBox(self: *Text) void {
        const mouse_pos = ray.GetMousePosition();
        const box_width = 200;
        const box_height = 100;

        // Draw a preview of the text box at the mouse position
        ray.DrawRectangleLines(@as(i32, @intFromFloat(mouse_pos.x)), @as(i32, @intFromFloat(mouse_pos.y)), box_width, box_height, ray.BLACK);

        // Draw some placeholder text
        ray.DrawTextEx(self.font, "Text Box", .{ .x = mouse_pos.x + 10, .y = mouse_pos.y + 10 }, 20, 1, ray.BLACK);
        self.placed = if (ray.IsMouseButtonPressed(ray.MOUSE_BUTTON_LEFT)) true else false;
    }

    pub fn createTextBox(self: *Text, x: comptime_int, y: comptime_int) !TextBox {
        const mouse_pos = ray.GetMousePosition();
        self.placed = true;

        return TextBox{
            .coords = mouse_pos,
            .dims = .{ .x = @floatFromInt(x), .y = @floatFromInt(y) },
        };
    }
};
