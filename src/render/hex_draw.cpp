#include "render/hex_draw.hpp"

#include <cmath>
#include <cstdio>

namespace cwl {
namespace {

void DrawFlatTopHex(Vector2 center, float circumradius, Color fill, bool outline,
                    Color outline_color, float outline_thick) {
  Vector2 pts[7];
  for (int i = 0; i < 6; ++i) {
    const float ang = static_cast<float>(i) * 60.0f * DEG2RAD;
    pts[i] = Vector2{center.x + circumradius * std::cos(ang),
                     center.y + circumradius * std::sin(ang)};
  }
  pts[6] = pts[0];
  for (int i = 0; i < 6; ++i) {
    DrawTriangle(center, pts[i], pts[i + 1], fill);
  }
  if (outline) {
    for (int i = 0; i < 6; ++i) {
      DrawLineEx(pts[i], pts[i + 1], outline_thick, outline_color);
    }
  }
}

const char* ResultText(BattleResult r) {
  switch (r) {
    case BattleResult::UnionWin:
      return "北軍勝利";
    case BattleResult::ConfederacyWin:
      return "南軍勝利";
    case BattleResult::Draw:
      return "引き分け";
    default:
      return "";
  }
}

}  // namespace

Color TerrainColor(Terrain t) {
  switch (t) {
    case Terrain::Plain:
      return Color{90, 130, 70, 255};
    case Terrain::Hill:
      return Color{110, 120, 60, 255};
    case Terrain::Mountain:
      return Color{120, 120, 125, 255};
    case Terrain::Sand:
      return Color{190, 175, 110, 255};
    case Terrain::Town:
      return Color{150, 90, 70, 255};
    case Terrain::Road:
      return Color{150, 140, 100, 255};
    case Terrain::River:
      return Color{50, 100, 170, 255};
    case Terrain::Valley:
      return Color{50, 90, 55, 255};
    case Terrain::Rock:
      return Color{100, 95, 90, 255};
    default:
      return Color{80, 80, 80, 255};
  }
}

Color SideColor(Side s) {
  return s == Side::Union ? Color{60, 100, 200, 255} : Color{180, 70, 60, 255};
}

void DrawHexCell(Hex h, Terrain t, float size, Vector2 origin, bool selected) {
  const Vec2f c = HexToPixel(h, size, Vec2f{origin.x, origin.y});
  const Vector2 center{c.x, c.y};
  constexpr float kRadiusScale = 1.02f;
  const float radius = size * kRadiusScale;
  const Color edge =
      selected ? Color{255, 230, 120, 255} : Color{40, 48, 58, 255};
  DrawFlatTopHex(center, radius, TerrainColor(t), true, edge,
                 selected ? 2.5f : 1.25f);

  const char* g = TerrainGlyph(t);
  const int fs = static_cast<int>(size * 0.35f);
  if (fs >= 8) {
    const int tw = MeasureText(g, fs);
    DrawText(g, static_cast<int>(c.x) - tw / 2,
             static_cast<int>(c.y) + static_cast<int>(size * 0.15f), fs,
             Color{20, 20, 25, 180});
  }
}

void DrawMap(const Map& map, float size, Vector2 origin) {
  for (int r = 0; r < map.height(); ++r) {
    for (int q = 0; q < map.width(); ++q) {
      DrawHexCell(Hex{q, r}, map.At(Hex{q, r}), size, origin, false);
    }
  }
}

void DrawUnits(const Battle& battle, float size, Vector2 origin) {
  const int sel = battle.selected_id();
  for (const Unit& u : battle.units()) {
    if (!u.alive) {
      continue;
    }
    const Vec2f c = HexToPixel(u.pos, size, Vec2f{origin.x, origin.y});
    const bool selected = (u.id == sel);
    const float ur = size * (selected ? 0.55f : 0.45f);
    Color col = SideColor(u.side);
    if (u.kind == UnitKind::General) {
      // Gold ring undertone for generals
      DrawCircle(static_cast<int>(c.x), static_cast<int>(c.y), ur + 3.f,
                 Color{200, 170, 60, 255});
    }
    DrawCircle(static_cast<int>(c.x), static_cast<int>(c.y), ur, col);
    if (selected) {
      DrawCircleLines(static_cast<int>(c.x), static_cast<int>(c.y), ur + 2.f,
                      Color{255, 230, 120, 255});
    }
    const char* g =
        u.kind == UnitKind::General ? "G" : SideGlyph(u.side);
    const int fs = static_cast<int>(size * 0.5f);
    const int tw = MeasureText(g, fs);
    DrawText(g, static_cast<int>(c.x) - tw / 2, static_cast<int>(c.y) - fs / 2 - 2, fs,
             Color{245, 245, 245, 255});
    // strength
    char st[8];
    std::snprintf(st, sizeof(st), "%d", u.strength);
    const int sfs = static_cast<int>(size * 0.32f);
    if (sfs >= 8) {
      const int stw = MeasureText(st, sfs);
      DrawText(st, static_cast<int>(c.x) - stw / 2,
               static_cast<int>(c.y) + static_cast<int>(size * 0.12f), sfs,
               Color{230, 230, 200, 255});
    }
  }
}

void DrawHud(const Battle& battle, int screen_w, int screen_h) {
  (void)screen_w;
  const Unit* sel = battle.Selected();
  char line[320];
  if (sel != nullptr && !battle.game_over()) {
    const Terrain ter = battle.map().At(sel->pos);
    std::snprintf(
        line, sizeof(line),
        "P3 手番:%s t=%d/%d | 選択:%s#%d MP%d%s STR%d | 損害 U:%.0f%% C:%.0f%% | %s",
        SideNameJa(battle.active()), battle.turn_index(), kTurnLimit,
        UnitKindGlyph(sel->kind), sel->id, sel->mp,
        sel->has_attacked ? " 攻撃済" : "", sel->strength,
        battle.DamageRatio(Side::Union) * 100.f,
        battle.DamageRatio(Side::Confederacy) * 100.f, TerrainNameJa(ter));
  } else if (!battle.game_over()) {
    std::snprintf(line, sizeof(line), "P3 手番:%s t=%d/%d", SideNameJa(battle.active()),
                  battle.turn_index(), kTurnLimit);
  } else {
    std::snprintf(line, sizeof(line), "結果: %s — %s", ResultText(battle.result()),
                  battle.result_reason().c_str());
  }
  DrawText(line, 12, 10, 16, Color{220, 215, 200, 255});

  if (!battle.game_over()) {
    DrawText(
        "Tab: unit  |  Arrows: move  |  A: attack  |  Enter: end turn  |  Esc: quit",
        12, 34, 15, Color{160, 165, 175, 255});
  } else {
    DrawText("Game over — Esc to quit", 12, 34, 18, Color{255, 200, 120, 255});
    // big banner
    const char* big = ResultText(battle.result());
    const int fs = 40;
    const int tw = MeasureText(big, fs);
    DrawText(big, (GetScreenWidth() - tw) / 2, GetScreenHeight() / 2 - 20, fs,
             Color{255, 230, 150, 255});
  }

  DrawRectangle(12, 56, 12, 12, SideColor(Side::Union));
  DrawText("U/G 北", 28, 54, 14, Color{200, 200, 210, 255});
  DrawRectangle(100, 56, 12, 12, SideColor(Side::Confederacy));
  DrawText("C/G 南", 116, 54, 14, Color{200, 200, 210, 255});

  DrawText("Aquia — Phase 3 combat (deterministic)", 12, screen_h - 28, 14,
           Color{120, 130, 140, 255});
}

}  // namespace cwl
