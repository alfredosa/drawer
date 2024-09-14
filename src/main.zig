const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});
const d = @import("drawer/drawer.zig");

const AppState = enum {
    Drawer,
    Menu,
};

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 450;
    ray.InitWindow(screenWidth, screenHeight, "Drawer");
    defer ray.CloseWindow();
    ray.SetTargetFPS(60);

    const currentState: AppState = .Drawer;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var drawer = try d.Drawer.init(allocator);
    defer drawer.deinit(allocator);

    while (!ray.WindowShouldClose()) {
        drawer.update();
        ray.BeginDrawing();
        ray.ClearBackground(ray.RAYWHITE);
        switch (currentState) {
            .Drawer => drawer.draw(),
            .Menu => unreachable,
        }
        ray.EndDrawing();
    }
}
