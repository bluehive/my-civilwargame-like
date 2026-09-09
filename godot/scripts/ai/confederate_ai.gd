extends RefCounted
class_name ConfederateAI
## Scouts wander away from friendlies; army marches toward scout contacts.

static func count_adj(state: BattleState, h: Hex, side: int, want_friend: bool) -> int:
	var n := 0
	for dir in 6:
		var occ := state.occupant_at(Hex.neighbor(h, dir))
		if occ == null or not occ.alive:
			continue
		var is_friend := occ.side == side
		if want_friend and is_friend:
			n += 1
		elif (not want_friend) and (not is_friend):
			n += 1
	return n


static func nearest_friend_dist(state: BattleState, unit: GameUnit) -> int:
	var best := 999
	for u in state.units:
		var o: GameUnit = u
		if not o.alive or o.id == unit.id or o.side != unit.side:
			continue
		best = mini(best, Hex.distance(unit.hex, o.hex))
	return best


static func contact_centroid(state: BattleState, side: int) -> Hex:
	var contacts := state.scout_contacts(side)
	if contacts.is_empty():
		return Hex.new(-1, -1)
	var sq := 0
	var sr := 0
	for c in contacts:
		var e: GameUnit = c
		sq += e.hex.q
		sr += e.hex.r
	var n := contacts.size()
	return Hex.new(int(round(float(sq) / float(n))), int(round(float(sr) / float(n))))


static func score_hex_scout(state: BattleState, unit: GameUnit, h: Hex) -> float:
	## Prefer distance from friendlies; mild north/south bias; avoid clustering.
	var score := 0.0
	var min_friend := 999
	for u in state.units:
		var o: GameUnit = u
		if not o.alive or o.id == unit.id or o.side != unit.side:
			continue
		min_friend = mini(min_friend, Hex.distance(h, o.hex))
	if min_friend >= 999:
		min_friend = 0
	score += float(min_friend) * 3.0
	if min_friend <= 1:
		score -= 8.0
	elif min_friend <= 2:
		score -= 3.0
	# Prefer mid-map scouting corridor.
	score -= absf(float(h.r) - 6.5) * 0.2
	score -= absf(float(h.q) - 7.5) * 0.05
	var t := state.game_map.at(h)
	if t == GameMap.Terrain.HILL:
		score += 1.5
	elif t == GameMap.Terrain.ROAD:
		score += 0.5
	return score


static func score_hex_army(state: BattleState, unit: GameUnit, h: Hex) -> float:
	var friends := count_adj(state, h, unit.side, true)
	var enemies := count_adj(state, h, unit.side, false)
	var score := 0.0
	if friends == 2 or friends == 3:
		score += 4.0
	elif friends <= 1:
		score -= 1.0
	else:
		score -= 2.0
	if enemies == 1 or enemies == 2:
		score += 6.0
	elif enemies >= 3:
		score -= 4.0
	var centroid := contact_centroid(state, unit.side)
	if centroid.q >= 0:
		var d := Hex.distance(h, centroid)
		score += float(12 - d) * 1.2
	else:
		# No contact yet: mild advance north (toward Union).
		score += float(14 - h.r) * 0.2
	if unit.kind == GameUnit.Kind.GENERAL:
		score += float(friends) * 1.5
		score -= float(enemies) * 2.5
		if centroid.q >= 0:
			# Generals trail slightly behind the contact push.
			score -= 1.0
	var t := state.game_map.at(h)
	if t == GameMap.Terrain.HILL or t == GameMap.Terrain.TOWN:
		score += 1.0
	elif t == GameMap.Terrain.ROAD:
		score += 0.5
	return score


static func score_hex(state: BattleState, unit: GameUnit, h: Hex) -> float:
	if unit.is_scout():
		return score_hex_scout(state, unit, h)
	return score_hex_army(state, unit, h)


static func best_destination(state: BattleState, unit: GameUnit) -> Hex:
	var options: Array = state.reachable_hexes()
	options.append(unit.hex)
	var best_h: Hex = unit.hex
	var best_s := -9999.0
	for opt in options:
		var h: Hex = opt
		var s := score_hex(state, unit, h)
		s += float((h.q * 13 + h.r * 7 + unit.id) % 5) * 0.01
		if s > best_s:
			best_s = s
			best_h = h
	return best_h


static func step_toward(from: Hex, goal: Hex) -> Hex:
	if from.equals(goal):
		return Hex.new(0, 0)
	var best := Hex.new(0, 0)
	var best_d := Hex.distance(from, goal)
	for dir in 6:
		var dlt := Hex.delta_from_dir(dir)
		var nd := Hex.distance(Hex.add(from, dlt), goal)
		if nd < best_d:
			best_d = nd
			best = dlt
	return best


static func decide_action(state: BattleState) -> String:
	var u := state.selected()
	if u == null:
		return "skip"
	# Scouts rarely attack; army attacks when adjacent / in range.
	if (not u.is_scout()) and state.find_attack_target(u) != null and not u.has_attacked:
		var enemies := count_adj(state, u.hex, u.side, false)
		var friends := count_adj(state, u.hex, u.side, true)
		if enemies >= 1 or friends <= 1:
			return "attack"
	var goal := best_destination(state, u)
	var delta := step_toward(u.hex, goal)
	if delta.q == 0 and delta.r == 0:
		if (not u.is_scout()) and state.find_attack_target(u) != null and not u.has_attacked:
			return "attack"
		return "skip"
	if state.try_move_selected(delta):
		return "move"
	if (not u.is_scout()) and state.find_attack_target(u) != null and not u.has_attacked:
		return "attack"
	return "skip"
