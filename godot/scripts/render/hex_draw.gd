extends Node2D
class_name BattleBoard
## Draws Aquia hex map + units. Fit/zoom/pan + blinking move range.

var state: BattleState
var hex_size: float = 16.0
var origin: Vector2 = Vector2(40, 40)
var pan: Vector2 = Vector2.ZERO
var zoom: float = 1.0
var min_hex: float = 8.0
var max_hex: float = 40.0
var _fit_hex: float = 16.0
var _fit_origin: Vector2 = Vector2(40, 40)
## Overall-fit bias: show ~20% larger than strict fit (pan if clipped).
const FIT_BOOST := 1.20
var _blink_t := 0.0
var _reachable: Array = []

func _process(delta: float) -> void:
	_blink_t += delta
	if state != null and not _reachable.is_empty():
		queue_redraw()

func bind_state(s: BattleState) -> void:
	state = s
	refresh_reachable()
	queue_redraw()

func refresh_reachable() -> void:
	_reachable = state.reachable_hexes() if state != null else []

func map_pixel_size(size: float) -> Vector2:
	if state == null or state.game_map == null:
		return Vector2.ZERO
	var w := state.game_map.width
	var h := state.game_map.height
	var pitch_x := size * 1.5
	var pitch_y := size * sqrt(3.0)
	var map_w := pitch_x * float(w - 1) + size * 2.0
	var map_h := pitch_y * float(h - 1) + pitch_y * 0.5 * float(w - 1) + size * 2.0
	return Vector2(map_w, map_h)

func fit_to_rect(area: Rect2) -> void:
	if state == null or state.game_map == null:
		return
	var pad := 6.0
	var avail := Vector2(maxf(40.0, area.size.x - pad * 2.0), maxf(40.0, area.size.y - pad * 2.0))
	var lo := min_hex
	var hi := max_hex
	var best := lo
	for _i in 24:
		var mid := (lo + hi) * 0.5
		var sz := map_pixel_size(mid)
		if sz.x <= avail.x and sz.y <= avail.y:
			best = mid
			lo = mid
		else:
			hi = mid
	_fit_hex = clampf(best * FIT_BOOST, min_hex, max_hex)
	hex_size = clampf(_fit_hex * zoom, min_hex, max_hex)
	var sz2 := map_pixel_size(hex_size)
	_fit_origin = Vector2(
		area.position.x + pad + (avail.x - sz2.x) * 0.5 + hex_size,
		area.position.y + pad + maxf(0.0, (avail.y - sz2.y) * 0.25) + hex_size
	)
	origin = _fit_origin + pan
	queue_redraw()

func adjust_zoom(delta: float) -> void:
	zoom = clampf(zoom + delta, 0.6, 2.5)
	hex_size = clampf(_fit_hex * zoom, min_hex, max_hex)
	origin = _fit_origin + pan
	queue_redraw()

func reset_view() -> void:
	zoom = 1.0
	pan = Vector2.ZERO
	hex_size = _fit_hex
	origin = _fit_origin
	queue_redraw()

func pan_by(delta: Vector2) -> void:
	pan += delta
	origin = _fit_origin + pan
	queue_redraw()

func _draw() -> void:
	if state == null or state.game_map == null:
		return
	var game_map := state.game_map
	var selected := state.selected()
	var attack_target: GameUnit = null
	if selected != null and not state.game_over():
		attack_target = state.find_attack_target(selected)

	var reach_keys: Dictionary = {}
	for rh in _reachable:
		var hx: Hex = rh
		reach_keys[hx.as_key()] = true

	# Blink alpha 0.25..0.75
	var blink := 0.25 + 0.50 * (0.5 + 0.5 * sin(_blink_t * TAU * 1.6))

	var glyph_px := clampi(int(hex_size * 0.55), 8, 14)
	var unit_font := clampi(int(hex_size * 0.65), 9, 16)
	var str_font := clampi(int(hex_size * 0.5), 8, 12)

	for r in game_map.height:
		for q in game_map.width:
			var h := Hex.new(q, r)
			var t: int = game_map.at(h)
			var center := Hex.to_pixel(h, hex_size, origin)
			var selected_hex := selected != null and selected.hex.equals(h)
			_draw_flat_hex(center, hex_size * 1.02, GameMap.terrain_color(t), selected_hex)
			if reach_keys.has(h.as_key()):
				_draw_flat_hex(
					center,
					hex_size * 0.92,
					Color(1.0, 0.95, 0.35, blink * 0.55),
					false
				)
				draw_arc(center, hex_size * 0.92, 0, TAU, 28, Color(1.0, 0.9, 0.2, blink), 2.0)
			draw_string(
				ThemeDB.fallback_font,
				center + Vector2(-glyph_px * 0.35, glyph_px * 0.35),
				GameMap.terrain_glyph(t),
				HORIZONTAL_ALIGNMENT_LEFT,
				-1,
				glyph_px,
				Color(0.08, 0.08, 0.1, 0.8)
			)

	for u in state.units:
		var unit: GameUnit = u
		if not unit.alive:
			continue
		# Player (Union) FOW: hide enemy scouts and unspotted enemies.
		if not state.is_spotted_by(GameUnit.Side.UNION, unit):
			continue
		var center := Hex.to_pixel(unit.hex, hex_size, origin)
		var is_sel := selected != null and selected.id == unit.id
		var is_tgt := attack_target != null and attack_target.id == unit.id
		var radius := hex_size * (0.48 if is_sel else 0.4)
		draw_circle(center, radius, unit.side_color())
		var ring := Color(1.0, 0.92, 0.35) if is_sel else (Color(1.0, 0.35, 0.25) if is_tgt else Color(0.05, 0.05, 0.08))
		draw_arc(center, radius, 0, TAU, 28, ring, 2.4 if is_sel or is_tgt else 1.6)
		draw_string(
			ThemeDB.fallback_font,
			center + Vector2(-unit_font * 0.35, unit_font * 0.35),
			unit.glyph(),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			unit_font,
			Color(1, 1, 1)
		)
		draw_string(
			ThemeDB.fallback_font,
			center + Vector2(-str_font * 0.5, radius + str_font),
			str(unit.strength),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			str_font,
			Color(0.95, 0.95, 0.85)
		)

func _draw_flat_hex(center: Vector2, radius: float, fill: Color, selected: bool) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i in 6:
		var ang := deg_to_rad(float(i) * 60.0)
		pts.append(center + Vector2(cos(ang), sin(ang)) * radius)
	draw_colored_polygon(pts, fill)
	if selected:
		for i in 6:
			draw_line(pts[i], pts[(i + 1) % 6], Color(1.0, 0.9, 0.45), 2.6)
	elif fill.a >= 0.99:
		for i in 6:
			draw_line(pts[i], pts[(i + 1) % 6], Color(0.16, 0.19, 0.23), 1.15)

func refresh() -> void:
	refresh_reachable()
	queue_redraw()
