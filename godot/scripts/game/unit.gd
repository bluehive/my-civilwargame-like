extends RefCounted
class_name GameUnit

enum Side { UNION, CONFEDERACY }
enum Kind { INFANTRY, GENERAL, SCOUT }

const INF_MP := 3
const INF_ATK := 3
const INF_DEF := 2
const INF_RANGE := 1
const INF_STR := 10
const GEN_MP := 2
const GEN_ATK := 1
const GEN_DEF := 1
const GEN_RANGE := 1
const GEN_STR := 5
const SCOUT_MP := 6
const SCOUT_ATK := 1
const SCOUT_DEF := 1
const SCOUT_RANGE := 1
const SCOUT_STR := 1
const SCOUT_DETECT := 4
const ARMY_DETECT := 2  ## non-scout detect radius

var id: int = 0
var side: int = Side.UNION
var kind: int = Kind.INFANTRY
var hex: Hex = Hex.new()
var mp: int = INF_MP
var mp_max: int = INF_MP
var strength: int = INF_STR
var strength_max: int = INF_STR
var attack: int = INF_ATK
var defense: int = INF_DEF
var range_tiles: int = INF_RANGE
var has_attacked: bool = false
var alive: bool = true

func is_scout() -> bool:
	return kind == Kind.SCOUT


static func make_infantry(uid: int, p_side: int, h: Hex) -> GameUnit:
	var u := GameUnit.new()
	u.id = uid
	u.side = p_side
	u.kind = Kind.INFANTRY
	u.hex = h
	u.mp = INF_MP
	u.mp_max = INF_MP
	u.strength = INF_STR
	u.strength_max = INF_STR
	u.attack = INF_ATK
	u.defense = INF_DEF
	u.range_tiles = INF_RANGE
	return u


static func make_general(uid: int, p_side: int, h: Hex) -> GameUnit:
	var u := GameUnit.new()
	u.id = uid
	u.side = p_side
	u.kind = Kind.GENERAL
	u.hex = h
	u.mp = GEN_MP
	u.mp_max = GEN_MP
	u.strength = GEN_STR
	u.strength_max = GEN_STR
	u.attack = GEN_ATK
	u.defense = GEN_DEF
	u.range_tiles = GEN_RANGE
	return u


static func make_scout(uid: int, p_side: int, h: Hex) -> GameUnit:
	var u := GameUnit.new()
	u.id = uid
	u.side = p_side
	u.kind = Kind.SCOUT
	u.hex = h
	u.mp = SCOUT_MP
	u.mp_max = SCOUT_MP
	u.strength = SCOUT_STR
	u.strength_max = SCOUT_STR
	u.attack = SCOUT_ATK
	u.defense = SCOUT_DEF
	u.range_tiles = SCOUT_RANGE
	return u


static func make_aquia_forces() -> Array:
	# Positions fit 16x14 Aquia. Two scouts per side forward of the line.
	return [
		make_infantry(1, Side.UNION, Hex.new(3, 1)),
		make_infantry(2, Side.UNION, Hex.new(7, 1)),
		make_infantry(3, Side.UNION, Hex.new(11, 2)),
		make_general(7, Side.UNION, Hex.new(6, 2)),
		make_scout(9, Side.UNION, Hex.new(5, 4)),
		make_scout(10, Side.UNION, Hex.new(10, 4)),
		make_infantry(4, Side.CONFEDERACY, Hex.new(4, 12)),
		make_infantry(5, Side.CONFEDERACY, Hex.new(8, 12)),
		make_infantry(6, Side.CONFEDERACY, Hex.new(12, 11)),
		make_general(8, Side.CONFEDERACY, Hex.new(8, 11)),
		make_scout(11, Side.CONFEDERACY, Hex.new(5, 9)),
		make_scout(12, Side.CONFEDERACY, Hex.new(10, 9)),
	]


static func compute_damage(atk: int, defense: int) -> int:
	return maxi(1, atk - defense / 2)


func glyph() -> String:
	if kind == Kind.GENERAL:
		return "G"
	if kind == Kind.SCOUT:
		return "S"
	return "U" if side == Side.UNION else "C"


func side_color() -> Color:
	return Color8(60, 100, 200) if side == Side.UNION else Color8(180, 70, 60)


func side_name_ja() -> String:
	return "北軍" if side == Side.UNION else "南軍"


func kind_name_ja() -> String:
	match kind:
		Kind.GENERAL:
			return "将軍"
		Kind.SCOUT:
			return "偵察"
		_:
			return "歩兵"
