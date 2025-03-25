class_name ShotgunUpgrade
extends Upgrade


func _init() -> void:
	name = "Shotgun"
	id = "shotgun"
	_category = UpgradeCategory.WEAPON
	priority = 100

	SignalBus.register_upgrade.emit(self)
	level_increased.connect(_on_level_increased)


func get_cost() -> int:
	return 1000


func can_buy() -> bool:
	return _level == 0


func get_label() -> String:
	if _level == 0:
		return name
	return name + " (OWNED)"
