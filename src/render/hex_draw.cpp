#include "render/hex_draw.hpp"

#include <cstdio>

namespace cwl {

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

void DrawHexCell(Hex h, Terrain t, float size, Vector2 origin, bool selected) {
  const Vec2f c = HexToPixel(h, size, Vec2f{origin.x, origin.y});
  const Vector2 center{c.x, c.y};
  // DrawPoly rotation 0 with 6 sides ≈ pointy-ish; flat-top uses rotation 0 for flat top in raylib? 
  // raylib DrawPoly: first vertex at angle rotation; rotation=0 starts at right.
  // For flat-top, rotate 30 degrees so top/bottom edges are flat.
  const float rot = 30.0f;
  DrawPoly(center, 6, size * 0.95f, rot, TerrainColor(t));
  DrawPolyLinesEx(center, 6, size * 0.95f, rot, selected ? 3.0f : 1.0f,
                  selected ? Color{255, 230, 120, 255} : Color{30, 30, 35, 200});

  const char* g = TerrainGlyph(t);
  const int fs = static_cast<int>(size * 0.7f);
  const int tw = MeasureText(g, fs);
  DrawText(g, static_cast<int>(c.x) - tw / 2, static_cast<int>(c.y) - fs / 2, fs,
           Color{20, 20, 25, 255});
}

void DrawMap(const Map& map, float size, Vector2 origin, Hex cursor) {
  for (int r = 0; r < map.height(); ++r) {
    for (int q = 0; q < map.width(); ++q) {
      const Hex h{q, r};
      DrawHexCell(h, map.At(h), size, origin, h == cursor);
    }
  }
}

void DrawHud(const Map& map, Hex cursor, int screen_w, int screen_h) {
  (void)screen_w;
  const Terrain t = map.At(cursor);
  char line[160];
  std::snprintf(line, sizeof(line),
                "Phase 1 Hex MVP  |  cursor q=%d r=%d  |  %s (%s)", cursor.q,
                cursor.r, TerrainNameJa(t), TerrainGlyph(t));
  DrawText(line, 12, 10, 18, Color{220, 215, 200, 255});

  DrawText("Arrows: move cursor  |  Esc: quit  |  legend:", 12, 36, 16,
           Color{160, 165, 175, 255});

  // Compact legend for all 9 terrains
  int x = 12;
  const int y = 58;
  for (int i = 0; i < static_cast<int>(Terrain::Count); ++i) {
    const Terrain tr = static_cast<Terrain>(i);
    DrawRectangle(x, y, 14, 14, TerrainColor(tr));
    char lab[32];
    std::snprintf(lab, sizeof(lab), "%s%s", TerrainGlyph(tr), TerrainNameJa(tr));
    DrawText(lab, x + 18, y - 1, 14, Color{200, 200, 200, 255});
    x += 18 + MeasureText(lab, 14) + 12;
    if (x > screen_w - 80) {
      break;  // avoid overflow on small windows
    }
  }

  DrawText("Aquia Creek (embedded, simplified)", 12, screen_h - 28, 16,
           Color{120, 130, 140, 255});
}

}  // namespace cwl
