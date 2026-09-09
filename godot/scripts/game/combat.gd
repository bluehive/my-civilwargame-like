extends RefCounted
class_name BattleState
## Port of C++ Battle (Phase 2–3): move / attack / turns / victory.

enum Result { ONGOING, UNION_WIN, CONFEDERACY_WIN, DRAW }

const TURN_LIMIT := 20

var game_map: GameMap
var units: Array = []
var active_side: int = GameUnit.Side.UNION
var selected_id: int = -1
var turn_index: int = 0
var initial_strength: Array[int] = [0, 0]
var result: int = Result.ONGOING
var result_reason: String = ""
var last_log: String = ""
# Each entry: {id, q, r, mp}
var _move_undo: Array = []

func setup() -> void:
	game_map = GameMap.make_aquia_creek()
	units = GameUnit.make_aquia_forces()
	initial_strength = [0, 0]
	for u in units:
		var unit: GameUnit = u
		initial_strength[unit.side] += unit.strength_max
	_refresh_side(GameUnit.Side.UNION)
	_refresh_side(GameUnit.Side.CONFEDERACY)
	_ensure_selection()
	last_log = "戦闘開始 — 偵察S×2(MP6・探知4)／本隊探知2・接触へ進軍  Tab/WE・SD・ZC/U/A/Enter"

func game_over() -> bool:
	return result != Result.ONGOING

func selected() -> GameUnit:
	return _unit_by_id(selected_id)

func occupant_at(h: Hex) -> GameUnit:
	for u in units:
		var unit: GameUnit = u
		if unit.alive and unit.hex.equals(h):
			return unit
	return null

func select_next(dir: int) -> void:
	if game_over():
		return
	_clear_move_undo()
	var ids: Array[int] = []
	for u in units:
		var unit: GameUnit = u
		if unit.alive and unit.side == active_side:
			ids.append(unit.id)
	if ids.is_empty():
		selected_id = -1
		return
	var idx := 0
	for i in ids.size():
		if ids[i] == selected_id:
			idx = i
			break
	var n := ids.size()
	if dir >= 0:
		idx = (idx + 1) % n
	else:
		idx = (idx - 1 + n) % n
	selected_id = ids[idx]
	last_log = "選択: %s" % _unit_label(selected())


func reachable_hexes() -> Array:
	## BFS of hexes the selected unit can still reach with remaining MP.
	var out: Array = []
	var u := selected()
	if u == null or not u.alive or u.side != active_side or game_over():
		return out
	# cost_so_far keyed by "q,r"
	var best: Dictionary = {}
	var start_key := u.hex.as_key()
	best[start_key] = 0
	var queue: Array = [u.hex]
	while not queue.is_empty():
		var cur: Hex = queue.pop_front()
		var cur_cost: int = int(best[cur.as_key()])
		for dir in 6:
			var nxt := Hex.neighbor(cur, dir)
			if not game_map.in_bounds(nxt):
				continue
			var step := GameMap.terrain_move_cost(game_map.at(nxt))
			if step < 0:
				continue
			var occ := occupant_at(nxt)
			if occ != null and occ.id != u.id:
				continue
			var nc := cur_cost + step
			if nc > u.mp:
				continue
			var nk := nxt.as_key()
			if best.has(nk) and int(best[nk]) <= nc:
				continue
			best[nk] = nc
			queue.append(nxt)
	for k in best.keys():
		if str(k) == start_key:
			continue
		var parts := str(k).split(",")
		out.append(Hex.new(int(parts[0]), int(parts[1])))
	return out

func try_move_selected(delta: Hex) -> bool:
	if game_over():
		return false
	var u := selected()
	if u == null or not u.alive or u.side != active_side:
		return false
	var nxt := Hex.add(u.hex, delta)
	if not game_map.in_bounds(nxt):
		return false
	var cost := GameMap.terrain_move_cost(game_map.at(nxt))
	if cost < 0 or u.mp < cost:
		last_log = "移動不可（地形/MP不足）"
		return false
	if occupant_at(nxt) != null:
		last_log = "移動不可（占有）"
		return false
	_move_undo.append({"id": u.id, "q": u.hex.q, "r": u.hex.r, "mp": u.mp})
	u.hex = nxt
	u.mp -= cost
	last_log = "%s が (%d,%d) へ移動（残MP %d）— Uで取消可" % [_unit_label(u), nxt.q, nxt.r, u.mp]
	return true


func detect_radius(unit: GameUnit) -> int:
	return GameUnit.SCOUT_DETECT if unit.is_scout() else GameUnit.ARMY_DETECT


func scout_contacts(side: int) -> Array:
	## Non-scout enemies within each living unit's detect radius.
	## Scouts: 4 / others: 2. Enemy scouts are never reported.
	var seen: Dictionary = {}
	var out: Array = []
	for u in units:
		var watcher: GameUnit = u
		if not watcher.alive or watcher.side != side:
			continue
		var radius := detect_radius(watcher)
		for v in units:
			var e: GameUnit = v
			if not e.alive or e.side == side or e.is_scout():
				continue
			if Hex.distance(watcher.hex, e.hex) > radius:
				continue
			if seen.has(e.id):
				continue
			seen[e.id] = true
			out.append(e)
	return out


func is_spotted_by(viewer_side: int, unit: GameUnit) -> bool:
	## Own units always known. Enemy scouts never spotted. Others need scout contact.
	if unit == null or not unit.alive:
		return false
	if unit.side == viewer_side:
		return true
	if unit.is_scout():
		return false
	for c in scout_contacts(viewer_side):
		var e: GameUnit = c
		if e.id == unit.id:
			return true
	return false


func find_attack_target(attacker: GameUnit) -> GameUnit:
	## In-range enemies: always pick lowest strength (energy).
	## If 2+ are adjacent (接面), still the weakest among those in range.
	var best: GameUnit = null
	for u in units:
		var e: GameUnit = u
		if not e.alive or e.side == attacker.side:
			continue
		var d := Hex.distance(attacker.hex, e.hex)
		if d < 1 or d > attacker.range_tiles:
			continue
		if best == null:
			best = e
			continue
		if e.strength < best.strength:
			best = e
		elif e.strength == best.strength and e.id < best.id:
			best = e
	return best

func try_attack_selected() -> bool:
	if game_over():
		return false
	var atk := selected()
	if atk == null or not atk.alive or atk.side != active_side or atk.has_attacked:
		last_log = "攻撃不可"
		return false
	var target := find_attack_target(atk)
	if target == null:
		last_log = "射程内に敵なし"
		return false
	var dmg := GameUnit.compute_damage(atk.attack, target.defense)
	target.strength -= dmg
	if target.strength <= 0:
		target.strength = 0
		target.alive = false
		last_log = "%s が %s を撃破（dmg %d）" % [_unit_label(atk), _unit_label(target), dmg]
	else:
		last_log = "%s → %s に %d ダメージ（残%d）" % [
			_unit_label(atk), _unit_label(target), dmg, target.strength
		]
	atk.has_attacked = true
	_clear_move_undo()
	_evaluate_outcome()
	return true

func undo_last_move() -> bool:
	if game_over() or _move_undo.is_empty():
		last_log = "取り消せる移動がありません"
		return false
	var snap: Dictionary = _move_undo.pop_back()
	var u := _unit_by_id(int(snap["id"]))
	if u == null or not u.alive:
		last_log = "取消失敗"
		return false
	# Only undo if still selected / same unit turn
	if u.id != selected_id:
		_move_undo.append(snap)
		last_log = "選択中の部隊の移動だけ取消できます"
		return false
	u.hex = Hex.new(int(snap["q"]), int(snap["r"]))
	u.mp = int(snap["mp"])
	last_log = "%s の移動を取消 → (%d,%d) 残MP %d" % [_unit_label(u), u.hex.q, u.hex.r, u.mp]
	return true

func _clear_move_undo() -> void:
	_move_undo.clear()

func end_turn() -> void:
	if game_over():
		return
	_clear_move_undo()
	active_side = (
		GameUnit.Side.CONFEDERACY
		if active_side == GameUnit.Side.UNION
		else GameUnit.Side.UNION
	)
	turn_index += 1
	_refresh_side(active_side)
	selected_id = -1
	_ensure_selection()
	_evaluate_outcome()
	if game_over():
		return
	last_log = "%s の手番（ターン %d/%d）" % [
		"北軍" if active_side == GameUnit.Side.UNION else "南軍",
		turn_index,
		TURN_LIMIT,
	]

func living_strength(side: int) -> int:
	var sum := 0
	for u in units:
		var unit: GameUnit = u
		if unit.alive and unit.side == side:
			sum += unit.strength
	return sum

func damage_ratio(side: int) -> float:
	var initv: int = initial_strength[side]
	if initv <= 0:
		return 0.0
	return float(initv - living_strength(side)) / float(initv)

func general_count(side: int) -> int:
	var n := 0
	for u in units:
		var unit: GameUnit = u
		if unit.alive and unit.side == side and unit.kind == GameUnit.Kind.GENERAL:
			n += 1
	return n

func result_name_ja() -> String:
	match result:
		Result.UNION_WIN:
			return "北軍勝利"
		Result.CONFEDERACY_WIN:
			return "南軍勝利"
		Result.DRAW:
			return "引き分け"
		_:
			return "戦闘中"

func _evaluate_outcome() -> void:
	if result != Result.ONGOING:
		return
	if turn_index >= TURN_LIMIT:
		_set_result(Result.DRAW, "期間切れ（ターン上限）")
		return
	if general_count(GameUnit.Side.UNION) == 0:
		_set_result(Result.CONFEDERACY_WIN, "北軍将軍全滅")
		return
	if general_count(GameUnit.Side.CONFEDERACY) == 0:
		_set_result(Result.UNION_WIN, "南軍将軍全滅")
		return
	if damage_ratio(GameUnit.Side.UNION) >= 0.5:
		_set_result(Result.CONFEDERACY_WIN, "北軍損害50%以上")
		return
	if damage_ratio(GameUnit.Side.CONFEDERACY) >= 0.5:
		_set_result(Result.UNION_WIN, "南軍損害50%以上")
		return

func _set_result(r: int, reason: String) -> void:
	result = r
	result_reason = reason
	last_log = "%s — %s" % [result_name_ja(), reason]

func _ensure_selection() -> void:
	var cur := selected()
	if cur != null and cur.alive and cur.side == active_side:
		return
	for u in units:
		var unit: GameUnit = u
		if unit.alive and unit.side == active_side:
			selected_id = unit.id
			return
	selected_id = -1

func _refresh_side(side: int) -> void:
	for u in units:
		var unit: GameUnit = u
		if unit.alive and unit.side == side:
			unit.mp = unit.mp_max
			unit.has_attacked = false

func _unit_by_id(uid: int) -> GameUnit:
	for u in units:
		var unit: GameUnit = u
		if unit.id == uid:
			return unit
	return null

func _unit_label(u: GameUnit) -> String:
	if u == null:
		return "—"
	return "%s%s#%d" % [u.side_name_ja(), u.kind_name_ja(), u.id]
