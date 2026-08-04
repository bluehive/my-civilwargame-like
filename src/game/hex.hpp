// Axial hex coordinates (flat-top). Pure C++ — no raylib.
#pragma once

#include <cmath>
#include <cstdlib>

namespace cwl {

struct Hex {
  int q = 0;
  int r = 0;

  bool operator==(const Hex& o) const { return q == o.q && r == o.r; }
  bool operator!=(const Hex& o) const { return !(*this == o); }
};

// Flat-top neighbor directions (point order / movement).
inline constexpr Hex kHexDirs[6] = {
    {+1, 0}, {+1, -1}, {0, -1}, {-1, 0}, {-1, +1}, {0, +1},
};

inline Hex HexAdd(Hex a, Hex b) { return Hex{a.q + b.q, a.r + b.r}; }

inline Hex HexNeighbor(Hex h, int dir) {
  const Hex d = kHexDirs[((dir % 6) + 6) % 6];
  return HexAdd(h, d);
}

// Axial distance (cube metric / 2).
inline int HexDistance(Hex a, Hex b) {
  const int dq = a.q - b.q;
  const int dr = a.r - b.r;
  const int ds = (-a.q - a.r) - (-b.q - b.r);
  const int adq = dq < 0 ? -dq : dq;
  const int adr = dr < 0 ? -dr : dr;
  const int ads = ds < 0 ? -ds : ds;
  return (adq + adr + ads) / 2;
}

struct Vec2f {
  float x = 0.f;
  float y = 0.f;
};

// Flat-top honeycomb (size = circumradius = center → vertex).
// Neighbor center distance = √3 * size; shared edges meet when draw radius == size.
// Ref: https://www.redblobgames.com/grids/hexagons/#hex-to-pixel-axial
inline Vec2f HexToPixel(Hex h, float size, Vec2f origin) {
  const float x = size * (1.5f * static_cast<float>(h.q));
  const float y =
      size * (std::sqrt(3.f) * (static_cast<float>(h.r) +
                               0.5f * static_cast<float>(h.q)));
  return Vec2f{origin.x + x, origin.y + y};
}

// Horizontal / vertical center pitch (for layout / map sizing).
inline float HexPitchX(float size) { return size * 1.5f; }
inline float HexPitchY(float size) { return size * std::sqrt(3.f); }


// Map arrow keys → neighbor delta (MVP: cardinal axial steps).
inline Hex HexDeltaFromArrow(int key_right_left_up_down /* 0R 1L 2U 3D */) {
  switch (key_right_left_up_down) {
    case 0:
      return Hex{+1, 0};
    case 1:
      return Hex{-1, 0};
    case 2:
      return Hex{0, -1};
    case 3:
      return Hex{0, +1};
    default:
      return Hex{0, 0};
  }
}

}  // namespace cwl
