extends RefCounted
class_name GameUnit
## README roster: infantry, cavalry, transports, artillery, skirmisher, guard, general.

enum Side { UNION, CONFEDERACY }
enum Kind {
	INFANTRY,
	CAVALRY,
	WEAPON_TRANSPORT,
	SUPPLY_TRANSPORT,
	ARTILLERY,
	SKIRMISHER,
	GUARD,
	GENERAL,
}

const INF_MP := 3
const INF_ATK := 3
const INF_DEF := 2
const INF_RANGE := 1
const INF_STR := 10

const CAV_MP := 6
const CAV_ATK := 2
const CAV_DEF := 1
const CAV_RANGE := 1
const CAV_STR := 6
const CAV_DETECT := 4

const WPN_MP := 2
const WPN_ATK := 1
const WPN_DEF := 1
const WPN_RANGE := 1
const WPN_STR := 8

const SUP_MP := 2
const SUP_ATK := 0
const SUP_DEF := 1
const SUP_RANGE := 1
const SUP_STR := 8

const ART_MP := 2
const ART_ATK := 4
const ART_DEF := 1
const ART_RANGE := 2
const ART_STR := 7

const SK_MP := 4
const SK_ATK := 2
const SK_DEF := 1
const SK_RANGE := 2
const SK_STR := 5
const SK_DETECT := 3

const GRD_MP := 3
const GRD_ATK := 3
const GRD_DEF := 4
const GRD_RANGE := 1
const GRD_STR := 12

const GEN_MP := 2
const GEN_ATK := 1
const GEN_DEF := 1
const GEN_RANGE := 1
const GEN_STR := 5

const ARMY_DETECT := 2

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


func is_recon() -> bool:
	## Cavalry / skirmisher fill the former scout role (README has no 偵察).
	return kind == Kind.CAVALRY or kind == Kind.SKIRMISHER


func detect_radius() -> int:
	match kind:
		Kind.CAVALRY:
			return CAV_DETECT
		Kind.SKIRMISHER:
			return SK_DETECT
		_:
			return ARMY_DETECT


func is_hard_to_spot() -> bool:
	## Enemy cavalry stay hidden until very close (replaces invisible scouts).
	return kind == Kind.CAVALRY


static func _base(uid: int, p_side: int, h: Hex, p_kind: int, mp_v: int, str_v: int, atk: int, df: int, rng: int) -> GameUnit:
	var u := GameUnit.new()
	u.id = uid
	u.side = p_side
	u.kind = p_kind
	u.hex = h
	u.mp = mp_v
	u.mp_max = mp_v
	u.strength = str_v
	u.strength_max = str_v
	u.attack = atk
	u.defense = df
	u.range_tiles = rng
	return u


static func make_infantry(uid: int, p_side: int, h: Hex) -> GameUnit:
	return _base(uid, p_side, h, Kind.INFANTRY, INF_MP, INF_STR, INF_ATK, INF_DEF, INF_RANGE)


static func make_cavalry(uid: int, p_side: int, h: Hex) -> GameUnit:
	return _base(uid, p_side, h, Kind.CAVALRY, CAV_MP, CAV_STR, CAV_ATK, CAV_DEF, CAV_RANGE)


static func make_weapon_transport(uid: int, p_side: int, h: Hex) -> GameUnit:
	return _base(uid, p_side, h, Kind.WEAPON_TRANSPORT, WPN_MP, WPN_STR, WPN_ATK, WPN_DEF, WPN_RANGE)


static func make_supply_transport(uid: int, p_side: int, h: Hex) -> GameUnit:
	return _base(uid, p_side, h, Kind.SUPPLY_TRANSPORT, SUP_MP, SUP_STR, SUP_ATK, SUP_DEF, SUP_RANGE)


static func make_artillery(uid: int, p_side: int, h: Hex) -> GameUnit:
	return _base(uid, p_side, h, Kind.ARTILLERY, ART_MP, ART_STR, ART_ATK, ART_DEF, ART_RANGE)


static func make_skirmisher(uid: int, p_side: int, h: Hex) -> GameUnit:
	return _base(uid, p_side, h, Kind.SKIRMISHER, SK_MP, SK_STR, SK_ATK, SK_DEF, SK_RANGE)


static func make_guard(uid: int, p_side: int, h: Hex) -> GameUnit:
	return _base(uid, p_side, h, Kind.GUARD, GRD_MP, GRD_STR, GRD_ATK, GRD_DEF, GRD_RANGE)


static func make_general(uid: int, p_side: int, h: Hex) -> GameUnit:
	return _base(uid, p_side, h, Kind.GENERAL, GEN_MP, GEN_STR, GEN_ATK, GEN_DEF, GEN_RANGE)


static func make_aquia_forces() -> Array:
	## Fallback: level 1 builder lives in CampaignLevel.
	return CampaignLevel.build_forces(1)


static func compute_damage(atk: int, defense: int) -> int:
	return maxi(1, atk - defense / 2)


func glyph() -> String:
	match kind:
		Kind.GENERAL:
			return "G"
		Kind.CAVALRY:
			return "H"  # Horse
		Kind.WEAPON_TRANSPORT:
			return "W"
		Kind.SUPPLY_TRANSPORT:
			return "P"  # Provision
		Kind.ARTILLERY:
			return "A"
		Kind.SKIRMISHER:
			return "R"  # Rifle skirmish
		Kind.GUARD:
			return "N"  # Near-guard / 近衛
		_:
			return "U" if side == Side.UNION else "C"


func side_color() -> Color:
	return Color8(60, 100, 200) if side == Side.UNION else Color8(180, 70, 60)


func side_name_ja() -> String:
	return "北軍" if side == Side.UNION else "南軍"


func kind_name_ja() -> String:
	match kind:
		Kind.GENERAL:
			return "将軍"
		Kind.CAVALRY:
			return "騎馬"
		Kind.WEAPON_TRANSPORT:
			return "武器輸送"
		Kind.SUPPLY_TRANSPORT:
			return "物資輸送"
		Kind.ARTILLERY:
			return "大砲"
		Kind.SKIRMISHER:
			return "銃撃"
		Kind.GUARD:
			return "近衛"
		_:
			return "歩兵"
