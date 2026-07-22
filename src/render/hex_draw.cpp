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
  const float edge_thick = selected ? 2.5f : 1.25f;
  DrawFlatTopHex(center, radius, TerrainColor(t), true, edge, edge_thick);

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
    DrawCircle(static_cast<int>(c.x), static_cast<int>(c.y), ur, SideColor(u.side));
    if (selected) {
      DrawCircleLines(static_cast<int>(c.x), static_cast<int>(c.y), ur + 2.f,
                      Color{255, 230, 120, 255});
    }
    const char* g = SideGlyph(u.side);
    const int fs = static_cast<int>(size * 0.55f);
    const int tw = MeasureText(g, fs);
    DrawText(g, static_cast<int>(c.x) - tw / 2, static_cast<int>(c.y) - fs / 2, fs,
             Color{245, 245, 245, 255});
  }
}

void DrawHud(const Battle& battle, int screen_w, int screen_h) {
  (void)screen_w;
  const Unit* sel = battle.Selected();
  char line[256];
  if (sel != nullptr) {
    const Terrain ter = battle.map().At(sel->pos);
    std::snprintf(line, sizeof(line),
                  "Phase 2  |  手番:%s  |  選択:%s#%d MP %d/%d  |  q=%d r=%d %s",
                  SideNameJa(battle.active()), SideGlyph(sel->side), sel->id, sel->mp,
                  sel->mp_max, sel->pos.q, sel->pos.r, TerrainNameJa(ter));
  } else {
    std::snprintf(line, sizeof(line), "Phase 2  |  手番:%s  |  (no unit)",
                  SideNameJa(battle.active()));
  }
  DrawText(line, 12, 10, 18, Color{220, 215, 200, 255});

  DrawText("Tab: next unit  |  Arrows: move  |  Enter/Space: end turn  |  Esc: quit",
           12, 36, 16, Color{160, 165, 175, 255});

  DrawRectangle(12, 58, 14, 14, SideColor(Side::Union));
  DrawText("U 北軍", 30, 57, 16, Color{200, 200, 210, 255});
  DrawRectangle(100, 58, 14, 14, SideColor(Side::Confederacy));
  DrawText("C 南軍", 118, 57, 16, Color{200, 200, 210, 255});

  DrawText("Aquia Creek — infantry only (no combat yet)", 12, screen_h - 28, 16,
           Color{120, 130, 140, 255});
}

}  // namespace cwl
