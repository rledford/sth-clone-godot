class_name GameState
extends Resource

var _wave: int = 1

var _max_health: int = 100
var _health: int = _max_health

var _max_ammo: int = 7
var _ammo = _max_ammo

func get_health() -> int:
	return _health

func get_max_health() -> int:
	return _max_health

func get_wave() -> int:
	return _wave

func get_ammo() -> int:
	return _ammo

func get_max_ammo() -> int:
	return _max_ammo
