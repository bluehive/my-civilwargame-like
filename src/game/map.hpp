// Map + terrain (9 kinds). Pure C++ — no raylib.
#pragma once

#include "game/hex.hpp"

#include <string>
#include <vector>

namespace cwl {

enum class Terrain : unsigned char {
  Plain = 0,    // .
  Hill,         // ^
  Mountain,     // A
  Sand,         // :
  Town,         // #
  Road,         // =
  River,        // ~
  Valley,       // v
  Rock,         // *
  Count
};

const char* TerrainGlyph(Terrain t);
const char* TerrainNameJa(Terrain t);
Terrain TerrainFromChar(char c);

// Phase 2 movement: cost for infantry; -1 = impassable.
int TerrainMoveCost(Terrain t);
inline bool TerrainPassable(Terrain t) { return TerrainMoveCost(t) >= 0; }

class Map {
 public:
  int width() const { return width_; }
  int height() const { return height_; }

  bool InBounds(Hex h) const {
    return h.q >= 0 && h.r >= 0 && h.q < width_ && h.r < height_;
  }

  Terrain At(Hex h) const {
    if (!InBounds(h)) {
      return Terrain::Plain;
    }
    return cells_[static_cast<size_t>(h.r * width_ + h.q)];
  }

  // Load from row strings of equal length (glyph per cell).
  static Map FromRows(const char* const* rows, int row_count);

  // Embedded Aquia Creek (simplified) — Phase 1 static map.
  static Map MakeAquiaCreek();

 private:
  int width_ = 0;
  int height_ = 0;
  std::vector<Terrain> cells_;
};

}  // namespace cwl
