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

  // ~30% smaller than previous default 28 → denser honeycomb (more hexes on screen)
  float hex_size = 28.f * 0.7f;  // ≈ 19.6
  const float hex_size_min = 12.f;
  const float hex_size_max = 36.f;

  auto map_origin = [&](float size) -> Vector2 {
    // Center the honeycomb block in the play area under the HUD
    const float map_w =
        cwl::HexPitchX(size) * static_cast<float>(map.width() - 1) + size * 2.f;
    const float map_h =
        cwl::HexPitchY(size) * static_cast<float>(map.height() - 1) +
        cwl::HexPitchY(size) * 0.5f * static_cast<float>(map.width() - 1) +
        size * 2.f;
    const float play_top = 90.f;
    const float play_h = static_cast<float>(GetScreenHeight()) - play_top - 40.f;
    const float play_w = static_cast<float>(GetScreenWidth()) - 40.f;
    return Vector2{(play_w - map_w) * 0.5f + 20.f + size,
                   play_top + (play_h - map_h) * 0.35f + size};
  };

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
      hex_size = hex_size < hex_size_max ? hex_size + 1.f : hex_size;
    }
    if (IsKeyPressed(KEY_MINUS) || IsKeyPressed(KEY_KP_SUBTRACT)) {
      hex_size = hex_size > hex_size_min ? hex_size - 1.f : hex_size;
    }

    const Vector2 origin = map_origin(hex_size);

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
