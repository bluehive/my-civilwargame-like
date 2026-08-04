#include "game/unit.hpp"

#include <cstdio>

namespace cwl {

Battle::Battle(Map map, std::vector<Unit> units)
    : map_(std::move(map)), units_(std::move(units)), active_(Side::Union) {
  for (const Unit& u : units_) {
    initial_strength_[static_cast<int>(u.side)] += u.strength_max;
  }
  RefreshSide(Side::Union);
  RefreshSide(Side::Confederacy);
  EnsureSelection();
}

int Battle::LivingStrength(Side s) const {
  int sum = 0;
  for (const Unit& u : units_) {
    if (u.alive && u.side == s) {
      sum += u.strength;
    }
  }
  return sum;
}

float Battle::DamageRatio(Side s) const {
  const int init = initial_strength_[static_cast<int>(s)];
  if (init <= 0) {
    return 0.f;
  }
  const int lost = init - LivingStrength(s);
  return static_cast<float>(lost) / static_cast<float>(init);
}

int Battle::GeneralCount(Side s) const {
  int n = 0;
  for (const Unit& u : units_) {
    if (u.alive && u.side == s && u.kind == UnitKind::General) {
      ++n;
    }
  }
  return n;
}

const Unit* Battle::Selected() const {
  const int i = IndexOfId(selected_id_);
  if (i < 0) {
    return nullptr;
  }
  return &units_[static_cast<size_t>(i)];
}

Unit* Battle::Selected() {
  return const_cast<Unit*>(static_cast<const Battle*>(this)->Selected());
}

const Unit* Battle::OccupantAt(Hex h) const {
  for (const Unit& u : units_) {
    if (u.alive && u.pos == h) {
      return &u;
    }
  }
  return nullptr;
}

void Battle::SelectNext(int dir) {
  if (game_over()) {
    return;
  }
  std::vector<int> ids;
  for (const Unit& u : units_) {
    if (u.alive && u.side == active_) {
      ids.push_back(u.id);
    }
  }
  if (ids.empty()) {
    selected_id_ = -1;
    return;
  }
  int idx = 0;
  for (size_t i = 0; i < ids.size(); ++i) {
    if (ids[i] == selected_id_) {
      idx = static_cast<int>(i);
      break;
    }
  }
  const int n = static_cast<int>(ids.size());
  if (dir >= 0) {
    idx = (idx + 1) % n;
  } else {
    idx = (idx - 1 + n) % n;
  }
  selected_id_ = ids[static_cast<size_t>(idx)];
}

bool Battle::TryMoveSelected(Hex delta) {
  if (game_over()) {
    return false;
  }
  Unit* u = Selected();
  if (u == nullptr || !u->alive || u->side != active_) {
    return false;
  }
  const Hex next = HexAdd(u->pos, delta);
  if (!map_.InBounds(next)) {
    return false;
  }
  const int cost = TerrainMoveCost(map_.At(next));
  if (cost < 0 || u->mp < cost) {
    return false;
  }
  if (OccupantAt(next) != nullptr) {
    return false;
  }
  u->pos = next;
  u->mp -= cost;
  return true;
}

const Unit* Battle::FindAttackTarget(const Unit& attacker) const {
  const Unit* best = nullptr;
  int best_dist = 999;
  int best_id = 999999;
  for (const Unit& e : units_) {
    if (!e.alive || e.side == attacker.side) {
      continue;
    }
    const int d = HexDistance(attacker.pos, e.pos);
    if (d < 1 || d > attacker.range) {
      continue;
    }
    if (d < best_dist || (d == best_dist && e.id < best_id)) {
      best = &e;
      best_dist = d;
      best_id = e.id;
    }
  }
  return best;
}

bool Battle::TryAttackSelected() {
  if (game_over()) {
    return false;
  }
  Unit* atk = Selected();
  if (atk == nullptr || !atk->alive || atk->side != active_ || atk->has_attacked) {
    return false;
  }
  const Unit* target_c = FindAttackTarget(*atk);
  if (target_c == nullptr) {
    return false;
  }
  // mutable target
  Unit* target = nullptr;
  for (Unit& u : units_) {
    if (u.id == target_c->id) {
      target = &u;
      break;
    }
  }
  if (target == nullptr) {
    return false;
  }

  const int dmg = ComputeDamage(atk->attack, target->defense);
  ApplyDamage(*target, dmg);
  atk->has_attacked = true;
  EvaluateOutcome();
  return true;
}

void Battle::EndTurn() {
  if (game_over()) {
    return;
  }
  active_ = (active_ == Side::Union) ? Side::Confederacy : Side::Union;
  ++turn_index_;
  RefreshSide(active_);
  selected_id_ = -1;
  EnsureSelection();
  EvaluateOutcome();
}

void Battle::ApplyDamage(Unit& target, int dmg) {
  target.strength -= dmg;
  if (target.strength <= 0) {
    target.strength = 0;
    target.alive = false;
  }
}

void Battle::EvaluateOutcome() {
  if (result_ != BattleResult::Ongoing) {
    return;
  }
  // 1) turn limit → draw
  if (turn_index_ >= kTurnLimit) {
    SetResult(BattleResult::Draw, "期間切れ（ターン上限）");
    return;
  }
  // 2) general wiped
  if (GeneralCount(Side::Union) == 0) {
    SetResult(BattleResult::ConfederacyWin, "北軍将軍全滅");
    return;
  }
  if (GeneralCount(Side::Confederacy) == 0) {
    SetResult(BattleResult::UnionWin, "南軍将軍全滅");
    return;
  }
  // 3) 50% casualties
  if (DamageRatio(Side::Union) >= 0.5f) {
    SetResult(BattleResult::ConfederacyWin, "北軍損害50%以上");
    return;
  }
  if (DamageRatio(Side::Confederacy) >= 0.5f) {
    SetResult(BattleResult::UnionWin, "南軍損害50%以上");
    return;
  }
}

void Battle::SetResult(BattleResult r, const char* reason) {
  result_ = r;
  result_reason_ = reason;
}

void Battle::EnsureSelection() {
  const Unit* cur = Selected();
  if (cur != nullptr && cur->alive && cur->side == active_) {
    return;
  }
  for (const Unit& u : units_) {
    if (u.alive && u.side == active_) {
      selected_id_ = u.id;
      return;
    }
  }
  selected_id_ = -1;
}

void Battle::RefreshSide(Side s) {
  for (Unit& u : units_) {
    if (u.alive && u.side == s) {
      u.mp = u.mp_max;
      u.has_attacked = false;
    }
  }
}

int Battle::IndexOfId(int id) const {
  for (size_t i = 0; i < units_.size(); ++i) {
    if (units_[i].id == id) {
      return static_cast<int>(i);
    }
  }
  return -1;
}

}  // namespace cwl
