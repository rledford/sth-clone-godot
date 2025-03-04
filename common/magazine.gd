class_name Magazine
extends Resource

signal ammo_changed(ammo: int, max_ammo: int)
signal empty
signal full

var _max_ammo: int
var _ammo: int


func _init(ammo: int, max_ammo: int) -> void:
	_ammo = ammo
	_max_ammo = max_ammo


func get_ammo() -> int:
	return _ammo


func get_max_ammo() -> int:
	return _max_ammo


func has_ammo() -> bool:
	return not is_empty()


func is_empty() -> bool:
	return _ammo == 0


func is_full() -> bool:
	return _ammo == _max_ammo


func change_size(max_ammo: int) -> void:
	_change_ammo(_ammo, max_ammo)


func load(amount: int) -> void:
	_change_ammo(_ammo + amount)


func unload(amount: int) -> void:
	_change_ammo(_ammo - amount)


func new_clip() -> void:
	_change_ammo(_max_ammo)


func _change_ammo(ammo: int, max_ammo = _max_ammo) -> void:
	_ammo = clamp(ammo, 0, max_ammo)
	_max_ammo = max_ammo

	ammo_changed.emit(_ammo, _max_ammo)
	if is_full():
		full.emit()
	if is_empty():
		empty.emit()
