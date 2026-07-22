// Civil War Like — Phase 0 Hello (raylib)
// Empty window + title. Esc / window close to quit.
// Smoke: CIVIL_WAR_LIKE_SMOKE=1 or --smoke → auto-close after a few frames.

#include "raylib.h"

#include <cstdlib>
#include <cstring>

namespace {

constexpr int kScreenW = 960;
constexpr int kScreenH = 640;
constexpr const char* kTitle = "Civil War Like";

bool WantSmoke(int argc, char** argv) {
  if (const char* env = std::getenv("CIVIL_WAR_LIKE_SMOKE")) {
    if (env[0] == '1' || env[0] == 'y' || env[0] == 'Y') {
      return true;
    }
  }
  for (int i = 1; i < argc; ++i) {
    if (std::strcmp(argv[i], "--smoke") == 0) {
      return true;
    }
  }
  return false;
}

}  // namespace

int main(int argc, char** argv) {
  const bool smoke = WantSmoke(argc, argv);

  SetConfigFlags(FLAG_WINDOW_RESIZABLE | FLAG_VSYNC_HINT);
  InitWindow(kScreenW, kScreenH, kTitle);
  SetTargetFPS(60);
  SetExitKey(KEY_ESCAPE);

  int frames = 0;
  const int smoke_frames = 30;  // ~0.5s at 60fps

  while (!WindowShouldClose()) {
    BeginDrawing();
    ClearBackground(Color{28, 32, 40, 255});

    const int tw = MeasureText(kTitle, 36);
    DrawText(kTitle, (GetScreenWidth() - tw) / 2, GetScreenHeight() / 2 - 48, 36,
             Color{220, 210, 180, 255});
    DrawText("Phase 0 — Hello raylib", 24, 24, 20, Color{160, 170, 180, 255});
    DrawText("Esc: quit  |  experimental worktree scaffold", 24,
             GetScreenHeight() - 40, 18, Color{120, 130, 140, 255});

    // Simple placeholder hex (foreshadow Phase 1)
    const float cx = static_cast<float>(GetScreenWidth()) / 2.0f;
    const float cy = static_cast<float>(GetScreenHeight()) / 2.0f + 40.0f;
    const float r = 36.0f;
    DrawPoly(Vector2{cx, cy}, 6, r, 0.0f, Color{70, 90, 60, 255});
    DrawPolyLinesEx(Vector2{cx, cy}, 6, r, 0.0f, 2.0f, Color{140, 160, 100, 255});

    EndDrawing();

    if (smoke) {
      ++frames;
      if (frames >= smoke_frames) {
        break;
      }
    }
  }

  CloseWindow();
  return 0;
}
