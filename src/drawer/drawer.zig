const std = @import("std");
const btns = @import("../components/button.zig");
const ray = @cImport({
    @cInclude("raylib.h");
});
const text = @import("text.zig");
const canvas = @import("canvas.zig");
const shapes = @import("shapes.zig");

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
    canvas: canvas.Canvas,
    shapes: shapes.Shapes,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) !Self {
        const buttons = try btns.createButtons(allocator);

        var iconTextures: [4]ray.Texture2D = undefined;
        iconTextures[0] = ray.LoadTexture("assets/drawing/text-height.png");
        iconTextures[1] = ray.LoadTexture("assets/drawing/shapes.png");
        iconTextures[2] = ray.LoadTexture("assets/drawing/eraser.png");
        iconTextures[3] = ray.LoadTexture("assets/drawing/terminal.png");

        const t = try text.Text.init();
        const c = canvas.Canvas.init(allocator);
        const s = try shapes.Shapes.init();

        return Self{
            .currentTool = .Normal,
            .buttons = buttons,
            .currentCursor = ray.MOUSE_CURSOR_DEFAULT,
            .iconTextures = iconTextures,
            .text = t,
            .canvas = c,
            .shapes = s,
        };
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        allocator.free(self.buttons);
        for (self.iconTextures) |texture| {
            ray.UnloadTexture(texture);
        }
        self.text.deinit();
        self.canvas.deinit();
    }

    fn updateCursor(self: *Self) void {
        const newCursor = switch (self.currentTool) {
            .Text => ray.MOUSE_CURSOR_IBEAM,
            .Shapes => ray.MOUSE_CURSOR_CROSSHAIR,
            .Erase => ray.MOUSE_CURSOR_POINTING_HAND,
            .Normal => ray.MOUSE_CURSOR_DEFAULT,
        };

        if (self.currentCursor != newCursor) {
            self.currentCursor = newCursor;
            ray.SetMouseCursor(self.currentCursor);
        }
    }

    pub fn draw(self: *Self) void {
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
            .Shapes => {},
            .Erase => {},
            .Normal => {},
        }
        self.canvas.draw();
        self.shapes.draw();
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
            .Shapes => "SHAPING",
            .Erase => "ERASING",
            .Normal => "NORMAL",
        };

        const text_x = box_x + @divFloor((box_width - ray.MeasureText(mode_text, 20)), 2);
        const text_y = box_y + @divFloor((box_height - 20), 2);

        ray.DrawTextEx(self.text.font, mode_text, .{ .x = @floatFromInt(text_x), .y = @floatFromInt(text_y) }, 20, 1, ray.WHITE);
    }

    pub fn update_keybinds(self: *Self) void {
        if (ray.IsKeyPressed(ray.KEY_E)) {
            self.currentTool = .Erase;
        } else if (ray.IsKeyPressed(ray.KEY_N)) {
            self.currentTool = .Normal;
        } else if (ray.IsKeyPressed(ray.KEY_S)) {
            self.currentTool = .Shapes;
            self.shapes.start_selecting();
        } else if (ray.IsKeyPressed(ray.KEY_T)) {
            self.currentTool = .Text;
        }
    }

    pub fn update(self: *Self) void {
        self.update_keybinds();

        var button_clicked = false;

        // Check if a button was clicked
        for (self.buttons) |button| {
            if (button.isMouseOverButton() and ray.IsMouseButtonPressed(ray.MOUSE_BUTTON_LEFT)) {
                self.currentTool = button.tool;
                switch (button.tool) {
                    .Text => std.debug.print("Text clicked", .{}),
                    .Shapes => self.shapes.start_selecting(),
                    .Erase => std.debug.print("Erase clicked", .{}),
                    .Normal => std.debug.print("Normal clicked", .{}),
                }
                button_clicked = true;
                break;
            }
        }

        // If no button was clicked, handle tool actions
        if (!button_clicked) {
            switch (self.currentTool) {
                .Text => {
                    if (ray.IsMouseButtonPressed(ray.MOUSE_BUTTON_LEFT)) {
                        // Start measuring the text box
                        self.text.startMeasuring(ray.GetMousePosition());
                    } else if (ray.IsMouseButtonReleased(ray.MOUSE_BUTTON_LEFT)) {
                        // Finalize the text box and add it to the canvas
                        const tb = self.text.finalizeTextBox() catch |err| {
                            std.debug.print("Failed to create a box: {}\n", .{err});
                            return;
                        };

                        self.canvas.addItem(.{ .TextBox = tb }) catch |err| {
                            std.debug.print("Failed to add a box to the list: {}\n", .{err});
                            return;
                        };
                        std.debug.print("Canvas Items {d}", .{self.canvas.items.items.len});
                        self.currentTool = .Normal;
                    } else if (ray.IsMouseButtonDown(ray.MOUSE_BUTTON_LEFT)) {
                        // Update the dimensions of the text box being measured
                        self.text.updateMeasurement(ray.GetMousePosition());
                    }
                },
                .Shapes => {
                    // Implement similar logic for rectangle drawing
                    if (ray.IsMouseButtonPressed(ray.MOUSE_BUTTON_LEFT)) {
                        // self.shapes.start_selecting();
                    } else if (ray.IsMouseButtonReleased(ray.MOUSE_BUTTON_LEFT)) {
                        // Finalize rectangle and add to canvas
                    } else if (ray.IsMouseButtonDown(ray.MOUSE_BUTTON_LEFT)) {
                        // Update rectangle dimensions

                    }
                },
                .Erase => {
                    if (ray.IsMouseButtonDown(ray.MOUSE_BUTTON_LEFT)) {
                        // Perform erasing while the button is held down
                    }
                },
                .Normal => {
                    // Implement normal mode logic here, if any
                },
            }
        }
        self.updateCursor();
    }
};
