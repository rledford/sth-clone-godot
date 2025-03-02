class_name Health
extends Resource

signal health_changed(health: int, max_health: int)
signal took_damage
signal died

var _max_health: int
var _health: int


func _init(max_health: int) -> void:
	_max_health = max_health
	_health = max_health


func is_full() -> bool:
	return _health == _max_health


func get_health() -> int:
	return _health


func get_max_health() -> int:
	return _max_health


func take_damage(damage: int) -> void:
	_change_health(_health - damage)
	took_damage.emit()


func heal(amount: int) -> void:
	_change_health(_health + amount)


func _change_health(health: int, max_health = _max_health) -> void:
	_health = clampi(health, 0, max_health)
	_max_health = max(0, max_health)
	health_changed.emit(_health, _max_health)

	if _health == 0:
		died.emit()
		return
