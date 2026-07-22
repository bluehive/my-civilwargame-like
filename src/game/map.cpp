#include "game/map.hpp"

#include "data/aquia_creek.hpp"

#include <cstring>

namespace cwl {

const char* TerrainGlyph(Terrain t) {
  switch (t) {
    case Terrain::Plain:
      return ".";
    case Terrain::Hill:
      return "^";
    case Terrain::Mountain:
      return "A";
    case Terrain::Sand:
      return ":";
    case Terrain::Town:
      return "#";
    case Terrain::Road:
      return "=";
    case Terrain::River:
      return "~";
    case Terrain::Valley:
      return "v";
    case Terrain::Rock:
      return "*";
    default:
      return "?";
  }
}

const char* TerrainNameJa(Terrain t) {
  switch (t) {
    case Terrain::Plain:
      return "平地";
    case Terrain::Hill:
      return "丘";
    case Terrain::Mountain:
      return "山";
    case Terrain::Sand:
      return "砂地";
    case Terrain::Town:
      return "街";
    case Terrain::Road:
      return "道路";
    case Terrain::River:
      return "川";
    case Terrain::Valley:
      return "谷間";
    case Terrain::Rock:
      return "岩地";
    default:
      return "不明";
  }
}

Terrain TerrainFromChar(char c) {
  switch (c) {
    case '.':
      return Terrain::Plain;
    case '^':
      return Terrain::Hill;
    case 'A':
      return Terrain::Mountain;
    case ':':
      return Terrain::Sand;
    case '#':
      return Terrain::Town;
    case '=':
      return Terrain::Road;
    case '~':
      return Terrain::River;
    case 'v':
      return Terrain::Valley;
    case '*':
      return Terrain::Rock;
    default:
      return Terrain::Plain;
  }
}

Map Map::FromRows(const char* const* rows, int row_count) {
  Map m;
  if (row_count <= 0 || rows == nullptr || rows[0] == nullptr) {
    return m;
  }
  m.height_ = row_count;
  m.width_ = static_cast<int>(std::strlen(rows[0]));
  m.cells_.assign(static_cast<size_t>(m.width_ * m.height_), Terrain::Plain);
  for (int r = 0; r < m.height_; ++r) {
    const char* row = rows[r];
    if (row == nullptr) {
      continue;
    }
    for (int q = 0; q < m.width_ && row[q] != '\0'; ++q) {
      m.cells_[static_cast<size_t>(r * m.width_ + q)] = TerrainFromChar(row[q]);
    }
  }
  return m;
}

Map Map::MakeAquiaCreek() {
  return FromRows(data::kAquiaCreekRows, data::kAquiaCreekRowCount);
}

}  // namespace cwl
