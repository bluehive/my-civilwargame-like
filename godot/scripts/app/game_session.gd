extends Node
## Cross-scene session: selected campaign level (1–5).

var level: int = 1


func clamp_level(n: int) -> int:
	return clampi(n, 1, 5)


func set_level(n: int) -> void:
	level = clamp_level(n)
