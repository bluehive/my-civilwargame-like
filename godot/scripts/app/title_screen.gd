extends Control
## Title: numeric keys 1-5 select battlefield level, Enter starts, Esc quits.

@onready var label: Label = $Label

var _level: int = 1


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_level = GameSession.level
	_refresh()


func _refresh() -> void:
	var nl := "\n"
	var text := "南北戦争ライク（Godot）" + nl + nl
	text += "【レベル選択】キーボードの数字 1〜5" + nl
	text += "  ※ 1=アキア … 5=ゲティスバーグ（戦地）" + nl
	text += "現在: %d / 5  %s" % [_level, CampaignLevel.name_ja(_level)] + nl
	text += "北軍の操作ユニット数: %d（レベルが上がるほど増える）" % CampaignLevel.operable_union_count(_level) + nl
	text += "南軍: Lv1同等 → Lv5が最強" + nl + nl
	text += "Enter / Space : このレベルで戦闘開始" + nl
	text += "Esc : 終了"
	if label:
		label.text = text


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var e: InputEventKey = event
	if e.keycode >= KEY_1 and e.keycode <= KEY_5:
		_level = int(e.keycode - KEY_1) + 1
		GameSession.set_level(_level)
		_refresh()
		get_viewport().set_input_as_handled()
		return
	if e.keycode >= KEY_KP_1 and e.keycode <= KEY_KP_5:
		_level = int(e.keycode - KEY_KP_1) + 1
		GameSession.set_level(_level)
		_refresh()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("end_turn") or event.is_action_pressed("ui_accept"):
		GameSession.set_level(_level)
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file("res://scenes/battle.tscn")
	elif event.is_action_pressed("ui_back") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		get_tree().quit()
