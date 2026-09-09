extends Control
## Battle screen (G0). Esc → title.

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.is_action_pressed("ui_back") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file("res://scenes/title.tscn")
