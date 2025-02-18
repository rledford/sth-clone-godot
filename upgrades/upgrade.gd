extends Resource
class_name Upgrade


var name: String
var id: String
var _level: int = 0

signal level_increase
signal level_change(level: int)

func getCost() -> int:
	assert("getCost needs to be implemented in subclasses")
	return _level * 0

func getLevel() -> int:
	return _level

func getLabel() -> String:
	return name + " " + str(_level)

func _increment_level() -> void:
	_level += 1
	level_change.emit(_level)

func _on_level_increase() -> void:
	_increment_level()
