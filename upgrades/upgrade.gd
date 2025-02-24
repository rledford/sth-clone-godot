class_name Upgrade
extends Resource

@warning_ignore("UNUSED_SIGNAL")
signal level_increased
signal level_changed(level: int)

var name: String
var id: String
var _level: int = 0


func get_cost() -> int:
	@warning_ignore("ASSERT_ALWAYS_TRUE")
	assert("get_cost needs to be implemented in subclasses")
	return _level * 0


func get_label() -> String:
	return name + " " + str(_level)


func _increment_level() -> void:
	_level += 1
	level_changed.emit(_level)


func _on_level_increase() -> void:
	_increment_level()
