extends Control
## Title screen (G0). Enter/Space → battle, Esc → quit.

func _ready() -> void:
	# Ensure we fill the window even if anchors were incomplete.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.is_action_pressed("end_turn") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file("res://scenes/battle.tscn")
	elif event.is_action_pressed("ui_back") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		get_tree().quit()
