// Units + turn + combat outcome (Phase 2–3). Pure C++ — no raylib.
#pragma once

#include "game/hex.hpp"
#include "game/map.hpp"

#include <string>
#include <vector>

namespace cwl {

enum class Side : unsigned char { Union = 0, Confederacy = 1 };

enum class UnitKind : unsigned char { Infantry = 0, General = 1 };

enum class BattleResult : unsigned char {
  Ongoing = 0,
  UnionWin,
  ConfederacyWin,
  Draw,
};

inline const char* SideNameJa(Side s) {
  return s == Side::Union ? "北軍" : "南軍";
}

inline const char* SideGlyph(Side s) { return s == Side::Union ? "U" : "C"; }

inline const char* UnitKindGlyph(UnitKind k) {
  return k == UnitKind::General ? "G" : "I";
}

// Provisional Phase 3 stats (#7 approved).
inline constexpr int kInfantryMp = 3;
inline constexpr int kInfantryAtk = 3;
inline constexpr int kInfantryDef = 2;
inline constexpr int kInfantryRange = 1;
inline constexpr int kInfantryStr = 10;

inline constexpr int kGeneralMp = 2;
inline constexpr int kGeneralAtk = 1;
inline constexpr int kGeneralDef = 1;
inline constexpr int kGeneralRange = 1;
inline constexpr int kGeneralStr = 5;

inline constexpr int kTurnLimit = 20;  // half-turns (EndTurn count)

struct Unit {
  int id = 0;
  Side side = Side::Union;
  UnitKind kind = UnitKind::Infantry;
  Hex pos{};
  int mp = kInfantryMp;
  int mp_max = kInfantryMp;
  int strength = kInfantryStr;
  int strength_max = kInfantryStr;
  int attack = kInfantryAtk;
  int defense = kInfantryDef;
  int range = kInfantryRange;
  bool has_attacked = false;
  bool alive = true;
};

inline Unit MakeInfantry(int id, Side side, Hex pos) {
  return Unit{id,
              side,
              UnitKind::Infantry,
              pos,
              kInfantryMp,
              kInfantryMp,
              kInfantryStr,
              kInfantryStr,
              kInfantryAtk,
              kInfantryDef,
              kInfantryRange,
              false,
              true};
}

inline Unit MakeGeneral(int id, Side side, Hex pos) {
  return Unit{id,
              side,
              UnitKind::General,
              pos,
              kGeneralMp,
              kGeneralMp,
              kGeneralStr,
              kGeneralStr,
              kGeneralAtk,
              kGeneralDef,
              kGeneralRange,
              false,
              true};
}

// Deterministic damage (no RNG): max(1, atk - def/2)
inline int ComputeDamage(int atk, int def) {
  const int raw = atk - def / 2;
  return raw < 1 ? 1 : raw;
}

class Battle {
 public:
  explicit Battle(Map map, std::vector<Unit> units);

  const Map& map() const { return map_; }
  const std::vector<Unit>& units() const { return units_; }
  Side active() const { return active_; }
  int selected_id() const { return selected_id_; }
  int turn_index() const { return turn_index_; }
  bool game_over() const { return result_ != BattleResult::Ongoing; }
  BattleResult result() const { return result_; }
  const std::string& result_reason() const { return result_reason_; }

  int InitialStrength(Side s) const {
    return initial_strength_[static_cast<int>(s)];
  }
  int LivingStrength(Side s) const;
  float DamageRatio(Side s) const;
  int GeneralCount(Side s) const;

  const Unit* Selected() const;
  Unit* Selected();
  const Unit* OccupantAt(Hex h) const;

  void SelectNext(int dir);
  bool TryMoveSelected(Hex delta);
  // Attack nearest enemy in range. Returns true if an attack resolved.
  bool TryAttackSelected();
  void EndTurn();

  // Nearest living enemy in range of unit; nullptr if none.
  const Unit* FindAttackTarget(const Unit& attacker) const;

 private:
  void EnsureSelection();
  void RefreshSide(Side s);
  int IndexOfId(int id) const;
  void ApplyDamage(Unit& target, int dmg);
  void EvaluateOutcome();
  void SetResult(BattleResult r, const char* reason);

  Map map_;
  std::vector<Unit> units_;
  Side active_ = Side::Union;
  int selected_id_ = -1;
  int turn_index_ = 0;
  int initial_strength_[2] = {0, 0};
  BattleResult result_ = BattleResult::Ongoing;
  std::string result_reason_;
};

}  // namespace cwl
