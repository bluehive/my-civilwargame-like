// Units + turn state (Phase 2). Pure C++ — no raylib.
#pragma once

#include "game/hex.hpp"
#include "game/map.hpp"

#include <vector>

namespace cwl {

enum class Side : unsigned char { Union = 0, Confederacy = 1 };

inline const char* SideNameJa(Side s) {
  return s == Side::Union ? "北軍" : "南軍";
}

inline const char* SideGlyph(Side s) { return s == Side::Union ? "U" : "C"; }

inline constexpr int kInfantryMpMax = 3;

struct Unit {
  int id = 0;
  Side side = Side::Union;
  Hex pos{};
  int mp = kInfantryMpMax;
  int mp_max = kInfantryMpMax;
  bool alive = true;
};

// Infantry-only battle state: Tab select, arrow move, Enter end turn.
class Battle {
 public:
  explicit Battle(Map map, std::vector<Unit> units);

  const Map& map() const { return map_; }
  const std::vector<Unit>& units() const { return units_; }
  Side active() const { return active_; }
  int selected_id() const { return selected_id_; }

  const Unit* Selected() const;
  Unit* Selected();

  // Occupant of hex (alive only); nullptr if empty.
  const Unit* OccupantAt(Hex h) const;

  // Cycle selection among active side's living units. dir: +1 or -1.
  void SelectNext(int dir);

  // Try move selected unit by axial delta (usually 4-way arrows). Returns true if moved.
  bool TryMoveSelected(Hex delta);

  // End turn: switch side, refresh MP, select first unit of new side.
  void EndTurn();

 private:
  void EnsureSelection();
  void RefreshMpFor(Side s);
  int IndexOfId(int id) const;

  Map map_;
  std::vector<Unit> units_;
  Side active_ = Side::Union;
  int selected_id_ = -1;
};

}  // namespace cwl
