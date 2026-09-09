extends Control
## Title screen stub (G0). Enter/Space → battle, Esc → quit.

func _ready() -> void:
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("end_turn"):
		get_tree().change_scene_to_file("res://scenes/battle.tscn")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_back"):
		get_tree().quit()
		get_viewport().set_input_as_handled()
