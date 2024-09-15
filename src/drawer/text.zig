const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

pub const TextBox = struct {
    coords: ray.Vector2,
    dims: ray.Vector2,
};

pub const Text = struct {
    font: ray.Font,

    pub fn init() !Text {
        const font = ray.LoadFont("assets/fonts/ubuntu.ttf");
        if (font.texture.id == 0) {
            return error.FontLoadFailed;
        }
        return Text{ .font = font };
    }

    pub fn deinit(self: *Text) void {
        ray.UnloadFont(self.font);
    }

    pub fn previewTextBox(self: *const Text) void {
        const mouse_pos = ray.GetMousePosition();
        const box_width = 200;
        const box_height = 100;

        // Draw a preview of the text box at the mouse position
        ray.DrawRectangleLines(@as(i32, @intFromFloat(mouse_pos.x)), @as(i32, @intFromFloat(mouse_pos.y)), box_width, box_height, ray.BLACK);

        // Draw some placeholder text
        ray.DrawTextEx(self.font, "Text Box", .{ .x = mouse_pos.x + 10, .y = mouse_pos.y + 10 }, 20, 1, ray.BLACK);
    }
    pub fn placeTextBox() !TextBox {
        const mouse_pos = ray.GetMousePosition();
        const box_width = 200;
        const box_height = 100;

        return TextBox{
            .coords = mouse_pos,
            .dims = .{ .x = @floatFromInt(box_width), .y = @floatFromInt(box_height) },
        };
    }
};
