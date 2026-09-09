extends SceneTree

func _init() -> void:
	var title = load("res://scenes/title.tscn")
	var battle = load("res://scenes/battle.tscn")
	if title == null or battle == null:
		push_error("FAILED load scenes")
		quit(1)
		return
	var t = title.instantiate()
	var b = battle.instantiate()
	print("SMOKE_OK title=", t.get_class(), " children=", t.get_child_count())
	print("SMOKE_OK battle=", b.get_class(), " children=", b.get_child_count())
	t.free()
	b.free()
	quit(0)
