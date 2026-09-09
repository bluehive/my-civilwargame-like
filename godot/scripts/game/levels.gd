extends RefCounted
class_name CampaignLevel
## Levels 1-5 = README battlefields. Union roster grows; Conf stronger by L5.

static func name_ja(level: int) -> String:
	match clampi(level, 1, 5):
		1:
			return "Lv1 アキア・クリーク（同等）"
		2:
			return "Lv2 第一次ブルラン"
		3:
			return "Lv3 第二次ブルラン"
		4:
			return "Lv4 ストーンズ川"
		_:
			return "Lv5 ゲティスバーグ（南軍優勢）"


static func battlefield_en(level: int) -> String:
	match clampi(level, 1, 5):
		1:
			return "Aquia Creek"
		2:
			return "First Bull Run"
		3:
			return "Second Bull Run"
		4:
			return "Stones River"
		_:
			return "Gettysburg"


static func conf_aggression(level: int) -> float:
	return 0.6 + float(clampi(level, 1, 5) - 1) * 0.45


static func map_rows(level: int) -> PackedStringArray:
	match clampi(level, 1, 5):
		1:
			return PackedStringArray([
				"................",
				"....^^^^........",
				"...^^^^^^.......",
				"..~~.^^^^.......",
				".~~~~.^^........",
				"~~~~~~..........",
				"~~~~............",
				"....##==........",
				"....#===^.......",
				".....===^^......",
				"..vvv...........",
				".vvvv...........",
				"....****........",
				"....::::........",
			])
		2:
			return PackedStringArray([
				"................",
				"...^^^^.........",
				"..^^^^^^........",
				".~~.^^^^........",
				".~~~~^^^........",
				"..~~.^^.........",
				"...~~..====.....",
				"....~~##===^^...",
				".....~~===^^^...",
				"......~~.^^^^...",
				"..vv...~~.......",
				".vvvv...~~......",
				"...****.........",
				"....::::........",
			])
		3:
			return PackedStringArray([
				"................",
				"..^^^^^^^^......",
				".^^^^^^^^^^.....",
				"....^^^^........",
				"....====^^^^....",
				"...======^^^....",
				"..~~.====.......",
				".~~~~.##==^^....",
				".~~~~.#===^^^...",
				"..~~...===^^^^..",
				"..vvv....^^^^...",
				".vvvv...........",
				"...****.........",
				"....****........",
			])
		4:
			return PackedStringArray([
				"................",
				"...^^^^.........",
				"..^^^^^^........",
				".~~.^^^^........",
				".~~~~...........",
				"~~~~~~..........",
				"~~~~~~..====....",
				"~~~~##=======...",
				"....#===^^......",
				".....===^^^.....",
				"..vvv...........",
				".vvvv...........",
				"...****.........",
				"....****........",
			])
		_:
			return PackedStringArray([
				"................",
				"...^^^^^^.......",
				"..^^^^^^^^......",
				"....^^^^^^......",
				"....^^^^^^......",
				"....====^^^^....",
				"...##=======^^..",
				"...##===^^^^^^..",
				"....===^^^^^^^..",
				".....==^^^^^^^..",
				"..vvv...^^^^....",
				".vvvv....^^.....",
				"...****.........",
				"....****........",
			])


static func cleaned_rows(level: int) -> PackedStringArray:
	var raw := map_rows(level)
	var out: PackedStringArray = []
	for row in raw:
		var r := String(row).replace(" ", "")
		while r.length() < 16:
			r += "."
		if r.length() > 16:
			r = r.substr(0, 16)
		out.append(r)
	return out


static func operable_union_count(level: int) -> int:
	var n := 0
	for u in build_forces(level):
		if u.side == GameUnit.Side.UNION:
			n += 1
	return n


static func _buff_conf_infantry(u: GameUnit, level: int) -> void:
	var lv := clampi(level, 1, 5)
	var c_str_counts := [10, 11, 12, 13, 15]
	var c_atk_counts := [3, 3, 4, 4, 5]
	var c_def_counts := [2, 2, 3, 3, 4]
	u.strength = int(c_str_counts[lv - 1])
	u.strength_max = u.strength
	u.attack = int(c_atk_counts[lv - 1])
	u.defense = int(c_def_counts[lv - 1])


static func build_forces(level: int) -> Array:
	var lv := clampi(level, 1, 5)
	var units: Array = []
	var id := 1

	var n_inf := [Hex.new(2, 1), Hex.new(6, 1), Hex.new(10, 1), Hex.new(4, 2), Hex.new(8, 2)]
	var n_gen := [Hex.new(6, 2), Hex.new(3, 2), Hex.new(9, 2)]
	var n_cav := [Hex.new(9, 4), Hex.new(13, 4)]
	var n_sk := Hex.new(11, 3)
	var n_art := Hex.new(7, 3)
	var n_grd := Hex.new(5, 3)
	var n_wpn := Hex.new(1, 2)
	var n_sup := Hex.new(12, 2)

	var s_inf := [Hex.new(2, 12), Hex.new(6, 12), Hex.new(10, 12), Hex.new(4, 11), Hex.new(12, 11), Hex.new(14, 12), Hex.new(8, 12)]
	var s_gen := [Hex.new(6, 10), Hex.new(5, 10), Hex.new(11, 10)]
	var s_cav := [Hex.new(1, 9), Hex.new(12, 9)]
	var s_sk := Hex.new(10, 9)
	var s_art := Hex.new(9, 9)
	var s_grd := Hex.new(7, 11)
	var s_wpn := Hex.new(1, 11)
	var s_sup := Hex.new(13, 11)

	if lv == 1:
		units.append(GameUnit.make_infantry(id, GameUnit.Side.UNION, n_inf[0])); id += 1
		units.append(GameUnit.make_infantry(id, GameUnit.Side.UNION, n_inf[1])); id += 1
		units.append(GameUnit.make_general(id, GameUnit.Side.UNION, n_gen[0])); id += 1
		units.append(GameUnit.make_cavalry(id, GameUnit.Side.UNION, n_cav[0])); id += 1
		units.append(GameUnit.make_infantry(id, GameUnit.Side.CONFEDERACY, s_inf[0])); id += 1
		units.append(GameUnit.make_infantry(id, GameUnit.Side.CONFEDERACY, s_inf[1])); id += 1
		units.append(GameUnit.make_general(id, GameUnit.Side.CONFEDERACY, s_gen[0])); id += 1
		units.append(GameUnit.make_cavalry(id, GameUnit.Side.CONFEDERACY, s_cav[0])); id += 1
	elif lv == 2:
		units.append(GameUnit.make_infantry(id, GameUnit.Side.UNION, n_inf[0])); id += 1
		units.append(GameUnit.make_infantry(id, GameUnit.Side.UNION, n_inf[1])); id += 1
		units.append(GameUnit.make_general(id, GameUnit.Side.UNION, n_gen[0])); id += 1
		units.append(GameUnit.make_cavalry(id, GameUnit.Side.UNION, n_cav[0])); id += 1
		units.append(GameUnit.make_skirmisher(id, GameUnit.Side.UNION, n_sk)); id += 1
		for i in 3:
			var cu := GameUnit.make_infantry(id, GameUnit.Side.CONFEDERACY, s_inf[i]); id += 1
			_buff_conf_infantry(cu, lv)
			units.append(cu)
		units.append(GameUnit.make_general(id, GameUnit.Side.CONFEDERACY, s_gen[0])); id += 1
		units.append(GameUnit.make_cavalry(id, GameUnit.Side.CONFEDERACY, s_cav[0])); id += 1
		units.append(GameUnit.make_skirmisher(id, GameUnit.Side.CONFEDERACY, s_sk)); id += 1
	elif lv == 3:
		for i in 3:
			units.append(GameUnit.make_infantry(id, GameUnit.Side.UNION, n_inf[i])); id += 1
		units.append(GameUnit.make_general(id, GameUnit.Side.UNION, n_gen[0])); id += 1
		units.append(GameUnit.make_cavalry(id, GameUnit.Side.UNION, n_cav[0])); id += 1
		units.append(GameUnit.make_skirmisher(id, GameUnit.Side.UNION, n_sk)); id += 1
		units.append(GameUnit.make_artillery(id, GameUnit.Side.UNION, n_art)); id += 1
		for i in 4:
			var cu := GameUnit.make_infantry(id, GameUnit.Side.CONFEDERACY, s_inf[i]); id += 1
			_buff_conf_infantry(cu, lv)
			units.append(cu)
		units.append(GameUnit.make_general(id, GameUnit.Side.CONFEDERACY, s_gen[0])); id += 1
		units.append(GameUnit.make_general(id, GameUnit.Side.CONFEDERACY, s_gen[1])); id += 1
		units.append(GameUnit.make_cavalry(id, GameUnit.Side.CONFEDERACY, s_cav[0])); id += 1
		units.append(GameUnit.make_skirmisher(id, GameUnit.Side.CONFEDERACY, s_sk)); id += 1
		units.append(GameUnit.make_artillery(id, GameUnit.Side.CONFEDERACY, s_art)); id += 1
	elif lv == 4:
		for i in 3:
			units.append(GameUnit.make_infantry(id, GameUnit.Side.UNION, n_inf[i])); id += 1
		units.append(GameUnit.make_general(id, GameUnit.Side.UNION, n_gen[0])); id += 1
		units.append(GameUnit.make_general(id, GameUnit.Side.UNION, n_gen[1])); id += 1
		units.append(GameUnit.make_cavalry(id, GameUnit.Side.UNION, n_cav[0])); id += 1
		units.append(GameUnit.make_skirmisher(id, GameUnit.Side.UNION, n_sk)); id += 1
		units.append(GameUnit.make_artillery(id, GameUnit.Side.UNION, n_art)); id += 1
		units.append(GameUnit.make_guard(id, GameUnit.Side.UNION, n_grd)); id += 1
		units.append(GameUnit.make_supply_transport(id, GameUnit.Side.UNION, n_sup)); id += 1
		for i in 5:
			var cu := GameUnit.make_infantry(id, GameUnit.Side.CONFEDERACY, s_inf[i]); id += 1
			_buff_conf_infantry(cu, lv)
			units.append(cu)
		units.append(GameUnit.make_general(id, GameUnit.Side.CONFEDERACY, s_gen[0])); id += 1
		units.append(GameUnit.make_general(id, GameUnit.Side.CONFEDERACY, s_gen[1])); id += 1
		units.append(GameUnit.make_cavalry(id, GameUnit.Side.CONFEDERACY, s_cav[0])); id += 1
		units.append(GameUnit.make_cavalry(id, GameUnit.Side.CONFEDERACY, s_cav[1])); id += 1
		units.append(GameUnit.make_skirmisher(id, GameUnit.Side.CONFEDERACY, s_sk)); id += 1
		units.append(GameUnit.make_artillery(id, GameUnit.Side.CONFEDERACY, s_art)); id += 1
		units.append(GameUnit.make_guard(id, GameUnit.Side.CONFEDERACY, s_grd)); id += 1
		units.append(GameUnit.make_supply_transport(id, GameUnit.Side.CONFEDERACY, s_sup)); id += 1
	else:
		for i in 4:
			units.append(GameUnit.make_infantry(id, GameUnit.Side.UNION, n_inf[i])); id += 1
		units.append(GameUnit.make_general(id, GameUnit.Side.UNION, n_gen[0])); id += 1
		units.append(GameUnit.make_general(id, GameUnit.Side.UNION, n_gen[1])); id += 1
		units.append(GameUnit.make_cavalry(id, GameUnit.Side.UNION, n_cav[0])); id += 1
		units.append(GameUnit.make_cavalry(id, GameUnit.Side.UNION, n_cav[1])); id += 1
		units.append(GameUnit.make_skirmisher(id, GameUnit.Side.UNION, n_sk)); id += 1
		units.append(GameUnit.make_artillery(id, GameUnit.Side.UNION, n_art)); id += 1
		units.append(GameUnit.make_guard(id, GameUnit.Side.UNION, n_grd)); id += 1
		units.append(GameUnit.make_weapon_transport(id, GameUnit.Side.UNION, n_wpn)); id += 1
		units.append(GameUnit.make_supply_transport(id, GameUnit.Side.UNION, n_sup)); id += 1
		for i in 7:
			var cu := GameUnit.make_infantry(id, GameUnit.Side.CONFEDERACY, s_inf[i]); id += 1
			_buff_conf_infantry(cu, lv)
			units.append(cu)
		for gi in 3:
			var cg := GameUnit.make_general(id, GameUnit.Side.CONFEDERACY, s_gen[gi]); id += 1
			cg.strength = 8
			cg.strength_max = 8
			cg.attack = 2
			cg.defense = 3
			units.append(cg)
		units.append(GameUnit.make_cavalry(id, GameUnit.Side.CONFEDERACY, s_cav[0])); id += 1
		units.append(GameUnit.make_cavalry(id, GameUnit.Side.CONFEDERACY, s_cav[1])); id += 1
		units.append(GameUnit.make_skirmisher(id, GameUnit.Side.CONFEDERACY, s_sk)); id += 1
		units.append(GameUnit.make_artillery(id, GameUnit.Side.CONFEDERACY, s_art)); id += 1
		units.append(GameUnit.make_guard(id, GameUnit.Side.CONFEDERACY, s_grd)); id += 1
		units.append(GameUnit.make_weapon_transport(id, GameUnit.Side.CONFEDERACY, s_wpn)); id += 1
		units.append(GameUnit.make_supply_transport(id, GameUnit.Side.CONFEDERACY, s_sup)); id += 1

	return units
