class_name Magazine
extends Resource

var _max_ammo: int = 7
var _ammo = _max_ammo


func _init() -> void:
	ClipSizeUpgrade.new().level_changed.connect(_handle_clip_size_upgrade)


func get_ammo() -> int:
	return _ammo


func get_max_ammo() -> int:
	return _max_ammo


func has_ammo() -> bool:
	return _ammo > 0


func is_full() -> bool:
	return _ammo == _max_ammo


func load(amount: int) -> void:
	_change_ammo(_ammo + amount)


func unload(amount: int) -> void:
	_change_ammo(_ammo - amount)


func _handle_clip_size_upgrade(level: int):
	var max_ammo = 7 + level
	_change_ammo(_ammo, max_ammo)


func _change_ammo(ammo: int, max_ammo = _max_ammo) -> void:
	_ammo = clamp(ammo, 0, max_ammo)
	_max_ammo = max_ammo
	print("[Magazine]: Ammo changed to: ", _ammo, "/", _max_ammo)
	SignalBus.player_ammo_changed.emit(_ammo, _max_ammo)
