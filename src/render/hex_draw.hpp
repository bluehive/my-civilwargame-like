// Hex drawing: colored poly + ASCII glyph (text + shape).
#pragma once

#include "game/hex.hpp"
#include "game/map.hpp"

#include "raylib.h"

namespace cwl {

Color TerrainColor(Terrain t);

void DrawHexCell(Hex h, Terrain t, float size, Vector2 origin, bool selected);

void DrawMap(const Map& map, float size, Vector2 origin, Hex cursor);

void DrawHud(const Map& map, Hex cursor, int screen_w, int screen_h);

}  // namespace cwl
