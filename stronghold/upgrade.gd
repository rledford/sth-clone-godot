class_name StrongholdUpgrade
extends Upgrade

func _init() -> void:
	name = "Stronghold"
	id = "stronghold"
	_max_level = 2
	_category = UpgradeCategory.STRONGHOLD

	SignalBus.register_upgrade.emit(self)
	level_increased.connect(_on_level_increased)


func get_cost() -> int:
	return ceil(Scaling.exponential_growth(800, 2.5, _level))


func can_buy() -> bool:
	return not self.is_maxed()
