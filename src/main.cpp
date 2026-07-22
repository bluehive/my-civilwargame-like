// Civil War Like — Phase 1 Hex map MVP
// Arrow keys: move map cursor. Esc / close: quit.
// Smoke: CIVIL_WAR_LIKE_SMOKE=1 or --smoke → auto-close after a few frames.

#include "game/hex.hpp"
#include "game/map.hpp"
#include "render/hex_draw.hpp"

#include "raylib.h"

#include <cstdlib>
#include <cstring>

namespace {

constexpr int kScreenW = 960;
constexpr int kScreenH = 640;
constexpr const char* kTitle = "Civil War Like — Hex MVP";

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

void TryMove(cwl::Hex& cursor, const cwl::Map& map, cwl::Hex delta) {
  const cwl::Hex next = cwl::HexAdd(cursor, delta);
  if (map.InBounds(next)) {
    cursor = next;
  }
}

}  // namespace

int main(int argc, char** argv) {
  const bool smoke = WantSmoke(argc, argv);

  SetConfigFlags(FLAG_WINDOW_RESIZABLE | FLAG_VSYNC_HINT);
  InitWindow(kScreenW, kScreenH, kTitle);
  SetTargetFPS(60);
  SetExitKey(KEY_ESCAPE);

  const cwl::Map map = cwl::Map::MakeAquiaCreek();
  cwl::Hex cursor{map.width() / 2, map.height() / 2};

  float hex_size = 28.f;
  const Vector2 origin{80.f, 120.f};

  int frames = 0;
  const int smoke_frames = 45;

  while (!WindowShouldClose()) {
    // --- input (keyboard only) ---
    if (IsKeyPressed(KEY_RIGHT)) {
      TryMove(cursor, map, cwl::HexDeltaFromArrow(0));
    }
    if (IsKeyPressed(KEY_LEFT)) {
      TryMove(cursor, map, cwl::HexDeltaFromArrow(1));
    }
    if (IsKeyPressed(KEY_UP)) {
      TryMove(cursor, map, cwl::HexDeltaFromArrow(2));
    }
    if (IsKeyPressed(KEY_DOWN)) {
      TryMove(cursor, map, cwl::HexDeltaFromArrow(3));
    }
    if (IsKeyPressed(KEY_EQUAL) || IsKeyPressed(KEY_KP_ADD)) {
      hex_size = hex_size < 48.f ? hex_size + 2.f : hex_size;
    }
    if (IsKeyPressed(KEY_MINUS) || IsKeyPressed(KEY_KP_SUBTRACT)) {
      hex_size = hex_size > 16.f ? hex_size - 2.f : hex_size;
    }

    BeginDrawing();
    ClearBackground(Color{28, 32, 40, 255});
    cwl::DrawMap(map, hex_size, origin, cursor);
    cwl::DrawHud(map, cursor, GetScreenWidth(), GetScreenHeight());
    EndDrawing();

    if (smoke) {
      // Nudge cursor once so smoke exercises move path
      if (frames == 10) {
        TryMove(cursor, map, cwl::Hex{1, 0});
      }
      ++frames;
      if (frames >= smoke_frames) {
        break;
      }
    }
  }

  CloseWindow();
  return 0;
}
