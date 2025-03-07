class_name Upgrade
extends Resource

@warning_ignore("UNUSED_SIGNAL")
signal level_increased
signal level_changed(level: int)

enum UpgradeCategory {
	MAGAZINE,
	WEAPON,
	STRONGHOLD,
	HEALTH,
}

## Order of priorities, lower comes first
const CATEGORY_PRIORITIES = {
	UpgradeCategory.MAGAZINE: 0,
	UpgradeCategory.WEAPON: 1,
	UpgradeCategory.STRONGHOLD: 2,
	UpgradeCategory.HEALTH: 3,
}

var name: String
var id: String
var priority: int = -1

var _level: int = 0
var _category: UpgradeCategory


func can_buy() -> bool:
	return true


func get_cost() -> int:
	@warning_ignore("ASSERT_ALWAYS_TRUE")
	assert("get_cost needs to be implemented in subclasses")
	return _level * 0


func get_category() -> UpgradeCategory:
	return _category


func get_label() -> String:
	return name + " " + str(_level)


func get_level() -> int:
	return _level


func _increment_level() -> void:
	_level += 1
	level_changed.emit(_level)


func _on_level_increased() -> void:
	_increment_level()
