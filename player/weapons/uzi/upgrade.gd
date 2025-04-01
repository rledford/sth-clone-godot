class_name UziUpgrade
extends Upgrade


func _init() -> void:
	name = "Uzi"
	id = "uzi"
	_category = UpgradeCategory.WEAPON
	priority = 99

	SignalBus.register_upgrade.emit(self)
	level_increased.connect(_on_level_increased)


func get_cost() -> int:
	if _level == 0:
		return 500
	return ceil(Scaling.exponential_growth(200, 1.5, _level))
