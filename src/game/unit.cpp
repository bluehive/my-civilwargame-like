#include "game/unit.hpp"

namespace cwl {

Battle::Battle(Map map, std::vector<Unit> units)
    : map_(std::move(map)), units_(std::move(units)), active_(Side::Union) {
  RefreshMpFor(Side::Union);
  RefreshMpFor(Side::Confederacy);
  EnsureSelection();
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
  std::vector<int> ids;
  ids.reserve(units_.size());
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

void Battle::EndTurn() {
  active_ = (active_ == Side::Union) ? Side::Confederacy : Side::Union;
  RefreshMpFor(active_);
  selected_id_ = -1;
  EnsureSelection();
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

void Battle::RefreshMpFor(Side s) {
  for (Unit& u : units_) {
    if (u.alive && u.side == s) {
      u.mp = u.mp_max;
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
