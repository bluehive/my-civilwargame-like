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

struct Vec2f {
  float x = 0.f;
  float y = 0.f;
};

// Flat-top pixel center (size = outer radius to vertex).
inline Vec2f HexToPixel(Hex h, float size, Vec2f origin) {
  const float x = size * (1.5f * static_cast<float>(h.q));
  const float y =
      size * (std::sqrt(3.f) * 0.5f * static_cast<float>(h.q) +
              std::sqrt(3.f) * static_cast<float>(h.r));
  return Vec2f{origin.x + x, origin.y + y};
}

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
