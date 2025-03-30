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
	if _level == 0:
		return 1000
	return ceil(Scaling.exponential_growth(500, 1.5, _level))
