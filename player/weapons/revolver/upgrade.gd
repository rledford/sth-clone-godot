class_name RevolverUpgrade
extends Upgrade


func _init() -> void:
	name = "Revolver"
	id = "revolver"
	_category = UpgradeCategory.WEAPON
	priority = 2

	SignalBus.register_upgrade.emit(self)
	level_increased.connect(_on_level_increased)


func get_cost() -> int:
	return (_level * 15) + 10


func get_label() -> String:
	return name + " " + str(_level + 1)
