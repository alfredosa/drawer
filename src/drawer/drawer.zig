const std = @import("std");
const btns = @import("../components/button.zig");
const ray = @cImport({
    @cInclude("raylib.h");
});
const text = @import("text.zig");

const ButtonDimensions = struct {
    width: f32 = 40, // Default :)
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
    iconTextures: [4]ray.Texture2D,
    text: text.Text,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) !Self {
        const buttons = try createButtons(allocator);

        var iconTextures: [4]ray.Texture2D = undefined;
        iconTextures[0] = ray.LoadTexture("assets/drawing/text-height.png");
        iconTextures[1] = ray.LoadTexture("assets/drawing/shapes.png");
        iconTextures[2] = ray.LoadTexture("assets/drawing/eraser.png");
        iconTextures[3] = ray.LoadTexture("assets/drawing/terminal.png");

        const t = try text.Text.init();

        return Self{
            .currentTool = .Normal,
            .buttons = buttons,
            .currentCursor = ray.MOUSE_CURSOR_DEFAULT,
            .iconTextures = iconTextures,
            .text = t,
        };
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        allocator.free(self.buttons);
        for (self.iconTextures) |texture| {
            ray.UnloadTexture(texture);
        }
        self.text.deinit();
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
            .{ .rect = .{ .x = 10, .y = 5, .width = button_dims.width, .height = button_dims.height }, .text = "", .tool = .Text, .action = &btns.printClicked },
            .{ .rect = .{ .x = 70, .y = 5, .width = button_dims.width, .height = button_dims.height }, .text = "", .tool = .Rectangle, .action = &btns.printClicked },
            .{ .rect = .{ .x = 130, .y = 5, .width = button_dims.width, .height = button_dims.height }, .text = "", .tool = .Erase, .action = &btns.printClicked },
            .{ .rect = .{ .x = 190, .y = 5, .width = button_dims.width, .height = button_dims.height }, .text = "", .tool = .Normal, .action = &btns.printClicked },
        });
    }

    pub fn draw(self: *const Self) void {
        const colors = Colors{};

        ray.DrawRectangle(-1, 0, ray.GetScreenWidth(), 60, ray.LIGHTGRAY);
        ray.DrawRectangleLines(-1, 0, ray.GetScreenWidth(), 60, ray.BLACK);

        for (self.buttons, 0..) |button, i| {
            const isSelected = button.tool == self.currentTool;
            const isHovered = button.isMouseOverButton();
            const buttonColor = if (isSelected) colors.selected else if (isHovered) colors.hovered else colors.normal;

            ray.DrawRectangleRec(button.rect, buttonColor);
            ray.DrawRectangleLinesEx(button.rect, 2, ray.BLACK);

            // Draw the icon
            const iconColor = if (isSelected) ray.WHITE else ray.BLACK;
            const scale = @min((button.rect.width - 10) / @as(f32, @floatFromInt(self.iconTextures[i].width)), (button.rect.height - 10) / @as(f32, @floatFromInt(self.iconTextures[i].height)));
            ray.DrawTextureEx(self.iconTextures[i], .{ .x = button.rect.x + (button.rect.width - @as(f32, @floatFromInt(self.iconTextures[i].width)) * scale) / 2, .y = button.rect.y + (button.rect.height - @as(f32, @floatFromInt(self.iconTextures[i].height)) * scale) / 2 }, 0, scale, iconColor);
        }

        switch (self.currentTool) {
            .Text => self.text.previewTextBox(),
            .Rectangle => {},
            .Erase => {},
            .Normal => {},
        }
        self.draw_current_mode();
    }

    fn draw_current_mode(self: *const Self) void {
        // TODO: make colors a setting
        const screen_height = ray.GetScreenHeight();
        const box_width: c_int = 120;
        const box_height: c_int = 30;
        const padding: c_int = 10;

        const box_x = padding;
        const box_y = screen_height - box_height - padding;

        // Draw the box
        ray.DrawRectangle(box_x, box_y, box_width, box_height, ray.BLACK);

        // Draw the mode text
        const mode_text = switch (self.currentTool) {
            .Text => "TEXTING",
            .Rectangle => "SHAPING",
            .Erase => "ERASING",
            .Normal => "NORMAL",
        };

        const text_x = box_x + @divFloor((box_width - ray.MeasureText(mode_text, 20)), 2);
        const text_y = box_y + @divFloor((box_height - 20), 2);

        ray.DrawTextEx(self.text.font, mode_text, .{ .x = @floatFromInt(text_x), .y = @floatFromInt(text_y) }, 20, 1, ray.WHITE);
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
