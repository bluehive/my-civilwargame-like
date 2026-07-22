// Initial infantry placement for Aquia Creek (Phase 2). Embedded, no JSON.
#pragma once

#include "game/hex.hpp"
#include "game/unit.hpp"

#include <vector>

namespace cwl {
namespace data {

// Map is 20 x 16. North (Union) near top rows, South (Confederacy) near bottom.
inline std::vector<Unit> MakeAquiaInfantry() {
  std::vector<Unit> u;
  u.reserve(6);

  // Union — top-ish plain hexes
  u.push_back(Unit{1, Side::Union, Hex{4, 1}, kInfantryMpMax, kInfantryMpMax, true});
  u.push_back(Unit{2, Side::Union, Hex{8, 1}, kInfantryMpMax, kInfantryMpMax, true});
  u.push_back(Unit{3, Side::Union, Hex{12, 2}, kInfantryMpMax, kInfantryMpMax, true});

  // Confederacy — bottom-ish plain hexes
  u.push_back(Unit{4, Side::Confederacy, Hex{5, 14}, kInfantryMpMax, kInfantryMpMax, true});
  u.push_back(Unit{5, Side::Confederacy, Hex{9, 14}, kInfantryMpMax, kInfantryMpMax, true});
  u.push_back(Unit{6, Side::Confederacy, Hex{13, 13}, kInfantryMpMax, kInfantryMpMax, true});

  return u;
}

}  // namespace data
}  // namespace cwl
