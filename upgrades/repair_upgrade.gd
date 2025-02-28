class_name RepairUpgrade
extends Upgrade


func _init() -> void:
	name = "Repair"
	id = "repair"
	_category = UpgradeCategory.HEALTH
	priority = 1

	SignalBus.register_upgrade.emit(self)
	level_increased.connect(_on_level_increased)


func get_label() -> String:
	return name


func get_cost() -> int:
	return 20
