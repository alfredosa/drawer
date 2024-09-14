const btns = @import("../components/button.zig");
const ray = @cImport({
    @cInclude("raylib.h");
});

var currentTool: btns.Tool = .Text;

const buttonWidth = 120;
const buttonHeight = 40;
const buttons = [_]btns.ToolButton{
    .{ .rect = .{ .x = 10, .y = 10, .width = buttonWidth, .height = buttonHeight }, .text = "Text", .tool = .Text, .action = &btns.printClicked },
    .{ .rect = .{ .x = 140, .y = 10, .width = buttonWidth, .height = buttonHeight }, .text = "Rectangle", .tool = .Rectangle, .action = &btns.printClicked },
    .{ .rect = .{ .x = 270, .y = 10, .width = buttonWidth, .height = buttonHeight }, .text = "Erase", .tool = .Erase, .action = &btns.printClicked },
};

pub fn drawDrawer() void {
    // Draw toolbar background
    ray.DrawRectangle(-1, 0, ray.GetScreenWidth(), 60, ray.LIGHTGRAY);
    ray.DrawRectangleLines(-1, 0, ray.GetScreenWidth(), 60, ray.BLACK);

    // Draw buttons
    for (buttons) |button| {
        const isSelected = button.tool == currentTool;

        const isHovered = button.isMouseOverButton();

        const buttonColor = if (isSelected) ray.SKYBLUE else if (isHovered) ray.LIGHTGRAY else ray.WHITE;
        const textColor = if (isSelected) ray.WHITE else ray.BLACK;

        ray.DrawRectangleRec(button.rect, buttonColor);
        ray.DrawRectangleLinesEx(button.rect, 2, ray.BLACK);
        ray.DrawText(button.text.ptr, @as(c_int, @intFromFloat(button.rect.x + (buttonWidth - @as(f32, @floatFromInt(ray.MeasureText(button.text.ptr, 20)))) / 2)), @as(c_int, @intFromFloat(button.rect.y + 10)), 20, textColor);
    }

    switch (currentTool) {
        .Text => ray.DrawText("Text Tool Selected", 10, 100, 20, ray.BLACK),
        .Rectangle => ray.DrawText("Rectangle Tool Selected", 10, 100, 20, ray.BLACK),
        .Erase => ray.DrawText("Erase Tool Selected", 10, 100, 20, ray.BLACK),
    }
}

pub fn updateDrawer() void {
    if (ray.IsMouseButtonPressed(ray.MOUSE_BUTTON_LEFT)) {
        for (buttons) |button| {
            if (button.isMouseOverButton()) {
                currentTool = button.tool;
                button.action();
                break;
            }
        }
    }
}
