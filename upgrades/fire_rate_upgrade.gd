class_name FireRateUpgrade
extends Upgrade


func _init() -> void:
	name = "Fire Rate"
	id = "fire_rate"
	_category = UpgradeCategory.WEAPON
	priority = 2

	SignalBus.register_upgrade.emit(self)
	level_increased.connect(_on_level_increased)


func get_cost() -> int:
	return (_level * 15) + 10
