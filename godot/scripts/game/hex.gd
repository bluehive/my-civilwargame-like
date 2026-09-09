extends RefCounted
class_name Hex
## Axial hex (flat-top). Port of src/game/hex.hpp

var q: int = 0
var r: int = 0

func _init(p_q: int = 0, p_r: int = 0) -> void:
	q = p_q
	r = p_r

func equals(other: Hex) -> bool:
	return other != null and q == other.q and r == other.r

func as_key() -> String:
	return "%d,%d" % [q, r]

static func add(a: Hex, b: Hex) -> Hex:
	return Hex.new(a.q + b.q, a.r + b.r)

static func distance(a: Hex, b: Hex) -> int:
	var dq := a.q - b.q
	var dr := a.r - b.r
	var ds := (-a.q - a.r) - (-b.q - b.r)
	return (absi(dq) + absi(dr) + absi(ds)) / 2

static func neighbor(h: Hex, dir: int) -> Hex:
	var dirs := [
		Hex.new(1, 0), Hex.new(1, -1), Hex.new(0, -1),
		Hex.new(-1, 0), Hex.new(-1, 1), Hex.new(0, 1),
	]
	var d: Hex = dirs[((dir % 6) + 6) % 6]
	return add(h, d)

static func delta_from_dir(dir: int) -> Hex:
	return neighbor(Hex.new(0, 0), dir)

static func delta_from_arrow(dir: int) -> Hex:
	match dir:
		0:
			return Hex.new(1, 0)
		1:
			return Hex.new(-1, 0)
		2:
			return Hex.new(0, -1)
		3:
			return Hex.new(0, 1)
		_:
			return Hex.new(0, 0)

static func to_pixel(h: Hex, size: float, origin: Vector2) -> Vector2:
	var x := size * (1.5 * float(h.q))
	var y := size * (sqrt(3.0) * (float(h.r) + 0.5 * float(h.q)))
	return origin + Vector2(x, y)
