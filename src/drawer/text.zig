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
    measuring: bool,
    placed: bool,
    start_pos: ray.Vector2,
    current_pos: ray.Vector2,

    pub fn init() !Text {
        const font = ray.LoadFont("assets/fonts/ubuntu.ttf");
        if (font.texture.id == 0) {
            return error.FontLoadFailed;
        }
        return Text{
            .font = font,
            .placed = false,
            .measuring = false,
            .start_pos = .{ .x = 0, .y = 0 },
            .current_pos = .{ .x = 0, .y = 0 },
        };
    }

    pub fn deinit(self: *Text) void {
        ray.UnloadFont(self.font);
    }

    pub fn startMeasuring(self: *Text, pos: ray.Vector2) void {
        self.measuring = true;
        self.start_pos = pos;
        self.current_pos = pos;
    }

    pub fn updateMeasurement(self: *Text, pos: ray.Vector2) void {
        if (self.measuring) {
            self.current_pos = pos;
        }
    }

    pub fn finalizeTextBox(self: *Text) !TextBox {
        if (!self.measuring) {
            return error.NotMeasuring;
        }

        const min_x = @min(self.start_pos.x, self.current_pos.x);
        const min_y = @min(self.start_pos.y, self.current_pos.y);
        const width = @abs(self.current_pos.x - self.start_pos.x);
        const height = @abs(self.current_pos.y - self.start_pos.y);

        self.measuring = false;

        return TextBox{
            .coords = .{ .x = min_x, .y = min_y },
            .dims = .{ .x = width, .y = height },
        };
    }

    pub fn previewTextBox(self: *Text) void {
        const mouse_pos = ray.GetMousePosition();
        var min_x: f32 = undefined;
        var min_y: f32 = undefined;
        var width: f32 = undefined;
        var height: f32 = undefined;

        if (self.measuring) {
            min_x = @min(self.start_pos.x, self.current_pos.x);
            min_y = @min(self.start_pos.y, self.current_pos.y);
            width = @abs(self.current_pos.x - self.start_pos.x);
            height = @abs(self.current_pos.y - self.current_pos.y);
        } else {
            const default_width: f32 = 200;
            const default_height: f32 = 100;
            min_x = mouse_pos.x;
            min_y = mouse_pos.y;
            width = default_width;
            height = default_height;
        }

        // Ensure minimum dimensions
        const min_dimension: f32 = 20;
        width = @max(width, min_dimension);
        height = @max(height, min_dimension);

        // Draw the preview box
        ray.DrawRectangleLines(@as(i32, @intFromFloat(min_x)), @as(i32, @intFromFloat(min_y)), @as(i32, @intFromFloat(width)), @as(i32, @intFromFloat(height)), ray.BLACK);

        // Draw placeholder text
        const text = "Text Box";
        const font_size: f32 = 20;
        const text_width = ray.MeasureTextEx(self.font, text, font_size, 1).x;
        const text_height = font_size;

        const text_x = min_x + (width - text_width) / 2;
        const text_y = min_y + (height - text_height) / 2;

        ray.DrawTextEx(self.font, text, .{ .x = text_x, .y = text_y }, font_size, 1, ray.BLACK);
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
