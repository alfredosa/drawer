const std = @import("std");
const btns = @import("../components/button.zig");
const ray = @cImport({
    @cInclude("raylib.h");
});

const ButtonDimensions = struct {
    width: f32 = 120, // Default :)
    height: f32 = 40,
};

const Colors = struct {
    selected: ray.Color = ray.SKYBLUE,
    hovered: ray.Color = ray.LIGHTGRAY,
    normal: ray.Color = ray.WHITE,
    text_selected: ray.Color = ray.WHITE,
    text_normal: ray.Color = ray.BLACK,
};

pub const Drawer = struct {
    currentTool: btns.Tool,
    buttons: []const btns.ToolButton,
    currentCursor: c_int,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) !Self {
        const buttons = try createButtons(allocator);
        return Self{
            .currentTool = .Normal,
            .buttons = buttons,
            .currentCursor = ray.MOUSE_CURSOR_DEFAULT,
        };
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        allocator.free(self.buttons);
    }

    fn updateCursor(self: *Self) void {
        const newCursor = switch (self.currentTool) {
            .Text => ray.MOUSE_CURSOR_IBEAM,
            .Rectangle => ray.MOUSE_CURSOR_CROSSHAIR,
            .Erase => ray.MOUSE_CURSOR_POINTING_HAND,
            .Normal => ray.MOUSE_CURSOR_DEFAULT,
        };

        if (self.currentCursor != newCursor) {
            self.currentCursor = newCursor;
            ray.SetMouseCursor(self.currentCursor);
        }
    }

    fn createButtons(allocator: std.mem.Allocator) ![]const btns.ToolButton {
        const button_dims = ButtonDimensions{};
        return try allocator.dupe(btns.ToolButton, &[_]btns.ToolButton{
            .{ .rect = .{ .x = 10, .y = 10, .width = button_dims.width, .height = button_dims.height }, .text = "Text", .tool = .Text, .action = &btns.printClicked },
            .{ .rect = .{ .x = 140, .y = 10, .width = button_dims.width, .height = button_dims.height }, .text = "Rectangle", .tool = .Rectangle, .action = &btns.printClicked },
            .{ .rect = .{ .x = 270, .y = 10, .width = button_dims.width, .height = button_dims.height }, .text = "Erase", .tool = .Erase, .action = &btns.printClicked },
        });
    }

    pub fn draw(self: *const Self) void {
        const colors = Colors{};
        const button_dims = ButtonDimensions{};

        ray.DrawRectangle(-1, 0, ray.GetScreenWidth(), 60, ray.LIGHTGRAY);
        ray.DrawRectangleLines(-1, 0, ray.GetScreenWidth(), 60, ray.BLACK);

        for (self.buttons) |button| {
            const isSelected = button.tool == self.currentTool;
            const isHovered = button.isMouseOverButton();
            const buttonColor = if (isSelected) colors.selected else if (isHovered) colors.hovered else colors.normal;
            const textColor = if (isSelected) colors.text_selected else colors.text_normal;

            ray.DrawRectangleRec(button.rect, buttonColor);
            ray.DrawRectangleLinesEx(button.rect, 2, ray.BLACK);
            ray.DrawText(button.text.ptr, @as(c_int, @intFromFloat(button.rect.x + (button_dims.width - @as(f32, @floatFromInt(ray.MeasureText(button.text.ptr, 20)))) / 2)), @as(c_int, @intFromFloat(button.rect.y + 10)), 20, textColor);
        }

        switch (self.currentTool) {
            .Text => ray.DrawText("Text Tool Selected", 10, 100, 20, ray.BLACK),
            .Rectangle => ray.DrawText("Rectangle Tool Selected", 10, 100, 20, ray.BLACK),
            .Erase => ray.DrawText("Erase Tool Selected", 10, 100, 20, ray.BLACK),
            .Normal => ray.DrawText("This is noraml mode ;)", 10, 100, 20, ray.BLACK),
        }
    }

    pub fn update(self: *Self) void {
        if (ray.IsKeyDown(ray.KEY_N)) {
            self.currentTool = .Normal;
        }

        if (ray.IsMouseButtonPressed(ray.MOUSE_BUTTON_LEFT)) {
            for (self.buttons) |button| {
                if (button.isMouseOverButton()) {
                    self.currentTool = button.tool;
                    button.action();
                    break;
                }
            }
        }
        self.updateCursor();
    }
};
