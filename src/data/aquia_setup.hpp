// Initial forces for Aquia Creek (Phase 2–3). Embedded, no JSON.
#pragma once

#include "game/hex.hpp"
#include "game/unit.hpp"

#include <vector>

namespace cwl {
namespace data {

// Map 20x16. Infantry + 1 provisional general per side (Phase 3).
inline std::vector<Unit> MakeAquiaForces() {
  std::vector<Unit> u;
  u.reserve(8);

  // Union — north
  u.push_back(MakeInfantry(1, Side::Union, Hex{4, 1}));
  u.push_back(MakeInfantry(2, Side::Union, Hex{8, 1}));
  u.push_back(MakeInfantry(3, Side::Union, Hex{12, 2}));
  u.push_back(MakeGeneral(7, Side::Union, Hex{7, 2}));

  // Confederacy — south
  u.push_back(MakeInfantry(4, Side::Confederacy, Hex{5, 14}));
  u.push_back(MakeInfantry(5, Side::Confederacy, Hex{9, 14}));
  u.push_back(MakeInfantry(6, Side::Confederacy, Hex{13, 13}));
  u.push_back(MakeGeneral(8, Side::Confederacy, Hex{9, 13}));

  return u;
}

// Backward-compatible name
inline std::vector<Unit> MakeAquiaInfantry() { return MakeAquiaForces(); }

}  // namespace data
}  // namespace cwl
