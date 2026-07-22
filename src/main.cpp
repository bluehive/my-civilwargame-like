// Civil War Like — Phase 3: combat + victory
// Tab: cycle  |  Arrows: move  |  A: attack  |  Enter/Space: end turn  |  Esc: quit
// Smoke: CIVIL_WAR_LIKE_SMOKE=1 or --smoke

#include "data/aquia_setup.hpp"
#include "game/hex.hpp"
#include "game/map.hpp"
#include "game/unit.hpp"
#include "render/hex_draw.hpp"

#include "raylib.h"

#include <cstdlib>
#include <cstring>

namespace {

constexpr int kScreenW = 960;
constexpr int kScreenH = 640;
constexpr const char* kTitle = "Civil War Like — Phase 3 Combat";

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

// Deterministic combat smoke: move forces toward each other and trade blows.
void SmokeStep(cwl::Battle& battle, int frame) {
  // Early frames: Union march south
  if (frame == 10 || frame == 20 || frame == 30) {
    battle.TryMoveSelected(cwl::Hex{0, 1});
  }
  if (frame == 35) {
    battle.SelectNext(+1);
  }
  if (frame == 40 || frame == 50) {
    battle.TryMoveSelected(cwl::Hex{0, 1});
  }
  if (frame == 55) {
    battle.EndTurn();
  }
  // Confederacy march north
  if (frame == 65 || frame == 75 || frame == 85) {
    battle.TryMoveSelected(cwl::Hex{0, -1});
  }
  if (frame == 90) {
    battle.SelectNext(+1);
  }
  if (frame == 95 || frame == 105) {
    battle.TryMoveSelected(cwl::Hex{0, -1});
  }
  if (frame == 110) {
    battle.EndTurn();
  }
  // Try attacks for a while
  if (frame >= 120 && frame < 200 && (frame % 8) == 0) {
    if (!battle.TryAttackSelected()) {
      battle.SelectNext(+1);
      battle.TryAttackSelected();
    }
  }
  if (frame == 210) {
    battle.EndTurn();
  }
  if (frame >= 220 && frame < 300 && (frame % 8) == 0) {
    if (!battle.TryAttackSelected()) {
      battle.SelectNext(+1);
      battle.TryAttackSelected();
    }
  }
}

}  // namespace

int main(int argc, char** argv) {
  const bool smoke = WantSmoke(argc, argv);

  SetConfigFlags(FLAG_WINDOW_RESIZABLE | FLAG_VSYNC_HINT);
  InitWindow(kScreenW, kScreenH, kTitle);
  SetTargetFPS(60);
  SetExitKey(KEY_ESCAPE);

  cwl::Battle battle(cwl::Map::MakeAquiaCreek(), cwl::data::MakeAquiaForces());

  float hex_size = 28.f * 0.7f;
  const float hex_size_min = 12.f;
  const float hex_size_max = 36.f;

  auto map_origin = [&](float size) -> Vector2 {
    const auto& map = battle.map();
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
  const int smoke_frames = 360;  // longer to allow combat script

  while (!WindowShouldClose()) {
    if (!battle.game_over()) {
      if (IsKeyPressed(KEY_TAB)) {
        const bool back =
            IsKeyDown(KEY_LEFT_SHIFT) || IsKeyDown(KEY_RIGHT_SHIFT);
        battle.SelectNext(back ? -1 : +1);
      }
      if (IsKeyPressed(KEY_RIGHT)) {
        battle.TryMoveSelected(cwl::HexDeltaFromArrow(0));
      }
      if (IsKeyPressed(KEY_LEFT)) {
        battle.TryMoveSelected(cwl::HexDeltaFromArrow(1));
      }
      if (IsKeyPressed(KEY_UP)) {
        battle.TryMoveSelected(cwl::HexDeltaFromArrow(2));
      }
      if (IsKeyPressed(KEY_DOWN)) {
        battle.TryMoveSelected(cwl::HexDeltaFromArrow(3));
      }
      if (IsKeyPressed(KEY_A)) {
        battle.TryAttackSelected();
      }
      if (IsKeyPressed(KEY_ENTER) || IsKeyPressed(KEY_KP_ENTER) ||
          IsKeyPressed(KEY_SPACE)) {
        battle.EndTurn();
      }
    }

    if (IsKeyPressed(KEY_EQUAL) || IsKeyPressed(KEY_KP_ADD)) {
      hex_size = hex_size < hex_size_max ? hex_size + 1.f : hex_size;
    }
    if (IsKeyPressed(KEY_MINUS) || IsKeyPressed(KEY_KP_SUBTRACT)) {
      hex_size = hex_size > hex_size_min ? hex_size - 1.f : hex_size;
    }

    if (smoke) {
      SmokeStep(battle, frames);
    }

    const Vector2 origin = map_origin(hex_size);

    BeginDrawing();
    ClearBackground(Color{28, 32, 40, 255});
    cwl::DrawMap(battle.map(), hex_size, origin);
    cwl::DrawUnits(battle, hex_size, origin);
    cwl::DrawHud(battle, GetScreenWidth(), GetScreenHeight());
    EndDrawing();

    if (smoke) {
      ++frames;
      if (frames >= smoke_frames || battle.game_over()) {
        // brief hold on result if any
        if (battle.game_over() && frames < smoke_frames) {
          // keep drawing a few more frames
          if (frames < smoke_frames - 30) {
            frames = smoke_frames - 30;
          }
        }
        if (frames >= smoke_frames) {
          break;
        }
      }
    }
  }

  CloseWindow();
  return 0;
}
