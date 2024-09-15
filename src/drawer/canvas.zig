const std = @import("std");
const text = @import("text.zig");

pub const Canvas = struct {
    items: std.ArrayList(Item),
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .items = std.ArrayList(Item).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.items.deinit();
    }

    pub fn addItem(self: *Self, item: Item) !void {
        try self.items.append(item);
    }

    pub fn removeItem(self: *Self, index: usize) void {
        _ = self.items.orderedRemove(index);
    }

    pub fn draw(self: *const Self) void {
        for (self.items.items) |item| {
            switch (item) {
                .TextBox => |textbox| textbox.draw(),
            }
        }
    }
    pub fn update(self: *Item) void {
        switch (self.*) {
            .TextBox => |*textbox| textbox.update(),
            // Add other item types here
        }
    }
};

const Item = union(enum) {
    TextBox: text.TextBox,
    // Add other item types here as needed
};
