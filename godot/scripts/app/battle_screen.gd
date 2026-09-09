extends Control
## Union = player, Confederacy = scout-contact AI.

@onready var board: BattleBoard = $Board
@onready var hud: Label = $Hud
@onready var log_label: Label = $Log
@onready var help_label: Label = $Help
@onready var victory_banner: Label = $VictoryBanner
@onready var bgm: MarchBgm = $MarchBgm

var state: BattleState
var _ai_busy := false
const PAN_STEP := 28.0
const AI_STEP_SEC := 0.28

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	state = BattleState.new()
	state.setup(GameSession.level)
	if board:
		board.bind_state(state)
	_layout_and_fit()
	get_viewport().size_changed.connect(_layout_and_fit)
	_refresh_hud()

func _layout_and_fit() -> void:
	var vp := get_viewport_rect().size
	hud.offset_left = 8
	hud.offset_top = 4
	hud.offset_right = vp.x - 8
	hud.offset_bottom = 78
	log_label.offset_left = 8
	log_label.offset_top = vp.y - 54
	log_label.offset_right = vp.x - 8
	log_label.offset_bottom = vp.y - 28
	help_label.offset_left = 8
	help_label.offset_top = vp.y - 26
	help_label.offset_right = vp.x - 8
	help_label.offset_bottom = vp.y - 4
	var area := Rect2(Vector2(4, 82), Vector2(vp.x - 8, maxf(120.0, vp.y - 82 - 58)))
	if board:
		board.fit_to_rect(area)

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_EQUAL or event.keycode == KEY_KP_ADD:
		if board:
			board.adjust_zoom(0.1)
			_layout_and_fit_keep_zoom()
		get_viewport().set_input_as_handled()
		return
	if event.keycode == KEY_MINUS or event.keycode == KEY_KP_SUBTRACT:
		if board:
			board.adjust_zoom(-0.1)
			_layout_and_fit_keep_zoom()
		get_viewport().set_input_as_handled()
		return
	if event.keycode == KEY_0:
		if board:
			board.reset_view()
			_layout_and_fit()
		get_viewport().set_input_as_handled()
		return
	if event.keycode == KEY_M:
		if bgm:
			bgm.toggle_mute()
			_refresh_hud()
		get_viewport().set_input_as_handled()
		return
	if event.shift_pressed and event.keycode in [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]:
		var d := Vector2.ZERO
		match event.keycode:
			KEY_LEFT:
				d = Vector2(PAN_STEP, 0)
			KEY_RIGHT:
				d = Vector2(-PAN_STEP, 0)
			KEY_UP:
				d = Vector2(0, PAN_STEP)
			KEY_DOWN:
				d = Vector2(0, -PAN_STEP)
		if board:
			board.pan_by(d)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_back") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file("res://scenes/title.tscn")
		return
	if state == null or _ai_busy:
		return
	if state.game_over():
		return
	if state.active_side != GameUnit.Side.UNION:
		return
	if event.is_action_pressed("unit_cycle"):
		var back := Input.is_key_pressed(KEY_SHIFT)
		state.select_next(-1 if back else 1)
		_after_action()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_U or event.keycode == KEY_BACKSPACE:
		state.undo_last_move()
		_after_action()
		get_viewport().set_input_as_handled()
	elif _try_hex_move(event):
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("attack") or event.keycode == KEY_A:
		if state.try_attack_selected():
			if bgm:
				bgm.pulse_combat_tempo()
		_after_action()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("end_turn") or event.is_action_pressed("ui_accept"):
		state.end_turn()
		_after_action()
		get_viewport().set_input_as_handled()
		if not state.game_over() and state.active_side == GameUnit.Side.CONFEDERACY:
			_run_confederate_turn()

func _try_hex_move(event: InputEventKey) -> bool:
	if event.shift_pressed:
		return false
	var dir := -1
	match event.keycode:
		KEY_D:
			dir = 0
		KEY_E:
			dir = 1
		KEY_W:
			dir = 2
		KEY_S:
			dir = 3
		KEY_Z:
			dir = 4
		KEY_C:
			dir = 5
		_:
			return false
	state.try_move_selected(Hex.delta_from_dir(dir))
	_after_action()
	return true

func _run_confederate_turn() -> void:
	_ai_busy = true
	state.last_log = "南軍思考中（騎馬接触→進軍）…"
	_refresh_hud()
	await get_tree().create_timer(0.35).timeout
	var ids: Array[int] = []
	for u in state.units:
		var unit: GameUnit = u
		if unit.alive and unit.side == GameUnit.Side.CONFEDERACY:
			ids.append(unit.id)
	for uid in ids:
		if state.game_over():
			break
		state.selected_id = uid
		state._clear_move_undo()
		_after_action()
		await get_tree().create_timer(AI_STEP_SEC).timeout
		for _pulse in 3:
			if state.game_over():
				break
			var u := state.selected()
			if u == null or not u.alive:
				break
			var act := ConfederateAI.decide_action(state)
			if act == "attack":
				if state.try_attack_selected():
					if bgm:
						bgm.pulse_combat_tempo()
				_after_action()
				await get_tree().create_timer(AI_STEP_SEC).timeout
				break
			elif act == "move":
				_after_action()
				await get_tree().create_timer(AI_STEP_SEC).timeout
				if state.find_attack_target(state.selected()) != null:
					if state.try_attack_selected():
						if bgm:
							bgm.pulse_combat_tempo()
					_after_action()
					await get_tree().create_timer(AI_STEP_SEC).timeout
				break
			else:
				break
	if not state.game_over():
		state.end_turn()
	_after_action()
	_ai_busy = false
	if state.game_over():
		_show_victory()
	else:
		state.last_log = "北軍の手番です"
		_refresh_hud()

func _layout_and_fit_keep_zoom() -> void:
	var z := board.zoom if board else 1.0
	var p := board.pan if board else Vector2.ZERO
	_layout_and_fit()
	if board:
		board.zoom = z
		board.pan = p
		board.hex_size = clampf(board._fit_hex * z, board.min_hex, board.max_hex)
		board.origin = board._fit_origin + p
		board.queue_redraw()

func _after_action() -> void:
	if board:
		board.refresh()
	_refresh_hud()
	if state != null and state.game_over():
		_show_victory()

func _show_victory() -> void:
	if victory_banner == null or state == null:
		return
	victory_banner.visible = true
	victory_banner.text = "%s！" % state.result_name_ja()
	match state.result:
		BattleState.Result.UNION_WIN:
			victory_banner.add_theme_color_override("font_color", Color(0.45, 0.7, 1.0))
		BattleState.Result.CONFEDERACY_WIN:
			victory_banner.add_theme_color_override("font_color", Color(1.0, 0.45, 0.4))
		_:
			victory_banner.add_theme_color_override("font_color", Color(1.0, 0.92, 0.45))

func _refresh_hud() -> void:
	if state == null:
		return
	var side := "北軍" if state.active_side == GameUnit.Side.UNION else "南軍(AI)"
	var sel := state.selected()
	var sel_txt := "—"
	if sel:
		sel_txt = "%s %s#%d  MP%d/%d  攻%d 防%d 射程%d 攻撃%s" % [
			sel.side_name_ja(), sel.kind_name_ja(), sel.id, sel.mp, sel.mp_max,
			sel.attack, sel.defense, sel.range_tiles, "済" if sel.has_attacked else "可",
		]
	var status := state.result_name_ja()
	if state.game_over():
		status = "%s（%s）" % [state.result_name_ja(), state.result_reason]
	var mute := "消音" if (bgm and bgm.muted) else "BGM"
	hud.text = "Lv%d %s | 手番:%s | 半ターン:%d/%d | %s | %s\n選択: %s\n北兵力%d  南兵力%d  北将軍%d  南将軍%d" % [
		state.level, CampaignLevel.name_ja(state.level), side, state.turn_index, BattleState.TURN_LIMIT, status, mute, sel_txt,
		state.living_strength(GameUnit.Side.UNION), state.living_strength(GameUnit.Side.CONFEDERACY),
		state.general_count(GameUnit.Side.UNION), state.general_count(GameUnit.Side.CONFEDERACY),
	]
	log_label.text = state.last_log
	help_label.text = "あなた=北軍  Tab/WE・SD・ZC/U/A/Enter  南軍AI  H=騎馬 R=銃撃  | +/- 0 Shift+矢印 | M Esc"
