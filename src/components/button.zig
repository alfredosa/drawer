const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

pub const Tool = enum {
    Text,
    Rectangle,
    Erase,
};

pub const ToolButton = struct {
    rect: ray.Rectangle,
    text: []const u8,
    action: *const fn () void,
    tool: Tool,

    pub fn isMouseOverButton(self: ToolButton) bool {
        return ray.CheckCollisionPointRec(ray.GetMousePosition(), self.rect);
    }
};

pub fn printClicked() void {
    std.debug.print("I was clicked\n", .{});
}
