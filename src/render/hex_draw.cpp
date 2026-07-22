#include "render/hex_draw.hpp"

#include <cmath>
#include <cstdio>

namespace cwl {
namespace {

// Flat-top regular hex: vertices at 0°, 60°, … (raylib y-down still has horizontal flats).
// Must match HexToPixel flat-top spacing or honeycomb gaps appear.
void DrawFlatTopHex(Vector2 center, float circumradius, Color fill, bool outline,
                    Color outline_color, float outline_thick) {
  Vector2 pts[7];
  for (int i = 0; i < 6; ++i) {
    const float ang = static_cast<float>(i) * 60.0f * DEG2RAD;
    pts[i] = Vector2{center.x + circumradius * std::cos(ang),
                     center.y + circumradius * std::sin(ang)};
  }
  pts[6] = pts[0];
  // Filled hex via triangle fan from center
  for (int i = 0; i < 6; ++i) {
    DrawTriangle(center, pts[i], pts[i + 1], fill);
  }
  if (outline) {
    DrawLineStrip(pts, 7, outline_color);
    // thicken slightly
    if (outline_thick > 1.5f) {
      DrawLineEx(pts[0], pts[1], outline_thick, outline_color);
      for (int i = 1; i < 6; ++i) {
        DrawLineEx(pts[i], pts[i + 1], outline_thick, outline_color);
      }
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

void DrawHexCell(Hex h, Terrain t, float size, Vector2 origin, bool selected) {
  const Vec2f c = HexToPixel(h, size, Vec2f{origin.x, origin.y});
  const Vector2 center{c.x, c.y};
  // Honeycomb: draw radius == spacing size; tiny overlap kills subpixel seams.
  // Always draw a visible edge so cells read against dark background.
  constexpr float kRadiusScale = 1.02f;
  const float radius = size * kRadiusScale;
  const Color edge =
      selected ? Color{255, 230, 120, 255} : Color{40, 48, 58, 255};
  const float edge_thick = selected ? 2.5f : 1.25f;
  DrawFlatTopHex(center, radius, TerrainColor(t), /*outline=*/true, edge,
                 edge_thick);

  const char* g = TerrainGlyph(t);
  const int fs = static_cast<int>(size * 0.5f);
  if (fs >= 8) {
    const int tw = MeasureText(g, fs);
    DrawText(g, static_cast<int>(c.x) - tw / 2, static_cast<int>(c.y) - fs / 2, fs,
             Color{20, 20, 25, 255});
  }
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
  const Terrain t = map.At(cursor);
  char line[192];
  std::snprintf(line, sizeof(line),
                "Phase 1 Hex MVP  |  %dx%d  |  q=%d r=%d  |  %s (%s)", map.width(),
                map.height(), cursor.q, cursor.r, TerrainNameJa(t), TerrainGlyph(t));
  DrawText(line, 12, 10, 18, Color{220, 215, 200, 255});

  DrawText("Arrows: cursor  |  +/-: zoom  |  Esc: quit", 12, 36, 16,
           Color{160, 165, 175, 255});

  int x = 12;
  const int y = 58;
  for (int i = 0; i < static_cast<int>(Terrain::Count); ++i) {
    const Terrain tr = static_cast<Terrain>(i);
    DrawRectangle(x, y, 12, 12, TerrainColor(tr));
    char lab[24];
    std::snprintf(lab, sizeof(lab), "%s", TerrainGlyph(tr));
    DrawText(lab, x + 16, y - 1, 14, Color{200, 200, 200, 255});
    x += 16 + MeasureText(lab, 14) + 10;
    if (x > screen_w - 40) {
      break;
    }
  }

  DrawText("Aquia Creek (honeycomb, embedded)", 12, screen_h - 28, 16,
           Color{120, 130, 140, 255});
}

}  // namespace cwl
