extends Node2D
## Battle screen stub (G0). Esc → title. Real hex/combat comes in G1+.

func _ready() -> void:
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_back"):
		get_tree().change_scene_to_file("res://scenes/title.tscn")
		get_viewport().set_input_as_handled()
