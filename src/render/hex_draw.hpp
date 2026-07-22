// Hex + unit drawing: colored poly + ASCII (text + shape).
#pragma once

#include "game/hex.hpp"
#include "game/map.hpp"
#include "game/unit.hpp"

#include "raylib.h"

namespace cwl {

Color TerrainColor(Terrain t);
Color SideColor(Side s);

void DrawHexCell(Hex h, Terrain t, float size, Vector2 origin, bool selected);

void DrawMap(const Map& map, float size, Vector2 origin);

void DrawUnits(const Battle& battle, float size, Vector2 origin);

void DrawHud(const Battle& battle, int screen_w, int screen_h);

}  // namespace cwl
