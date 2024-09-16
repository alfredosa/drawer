const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

pub const Tool = enum {
    Text,
    Shapes,
    Erase,
    Normal,
};

const ButtonDimensions = struct {
    width: f32 = 40,
    height: f32 = 40,
};

pub const ToolButton = struct {
    rect: ray.Rectangle,
    text: []const u8,
    tool: Tool,

    pub fn isMouseOverButton(self: ToolButton) bool {
        return ray.CheckCollisionPointRec(ray.GetMousePosition(), self.rect);
    }
};

pub fn createButtons(
    allocator: std.mem.Allocator,
) ![]const ToolButton {
    const button_dims = ButtonDimensions{};
    return try allocator.dupe(ToolButton, &[_]ToolButton{
        .{ .rect = .{ .x = 10, .y = 5, .width = button_dims.width, .height = button_dims.height }, .text = "", .tool = .Text },
        .{ .rect = .{ .x = 70, .y = 5, .width = button_dims.width, .height = button_dims.height }, .text = "", .tool = .Shapes },
        .{ .rect = .{ .x = 130, .y = 5, .width = button_dims.width, .height = button_dims.height }, .text = "", .tool = .Erase },
        .{ .rect = .{ .x = 190, .y = 5, .width = button_dims.width, .height = button_dims.height }, .text = "", .tool = .Normal },
    });
}
