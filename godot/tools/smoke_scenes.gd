extends SceneTree
func _init() -> void:
	var b = load("res://scenes/battle.tscn").instantiate()
	get_root().add_child(b)
	await process_frame
	await process_frame
	var st = b.state
	for u in st.units:
		if u.side == GameUnit.Side.CONFEDERACY and u.alive:
			st.selected_id = u.id
			break
	var act = ConfederateAI.decide_action(st)
	print("SMOKE_OK ai_act=", act)
	b.get_node("MarchBgm").pulse_combat_tempo()
	print("SMOKE_OK tempo=", b.get_node("MarchBgm").tempo_scale)
	st.result = BattleState.Result.CONFEDERACY_WIN
	st.result_reason = "test"
	b._show_victory()
	print("SMOKE_OK banner=", b.get_node("VictoryBanner").text)
	quit(0)
