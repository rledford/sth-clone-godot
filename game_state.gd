class_name GameState
extends Resource

var _wave: int = 1

var _max_health: int = 100
var _health: int = _max_health


func get_health() -> int:
	return _health


func get_max_health() -> int:
	return _max_health


func get_wave() -> int:
	return _wave
