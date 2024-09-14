const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});
const drawer = @import("drawer/drawer.zig");

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

    while (!ray.WindowShouldClose()) {
        drawer.updateDrawer();
        ray.BeginDrawing();
        ray.ClearBackground(ray.RAYWHITE);
        switch (currentState) {
            .Drawer => drawer.drawDrawer(),
            .Menu => unreachable,
        }
        ray.EndDrawing();
    }
}
