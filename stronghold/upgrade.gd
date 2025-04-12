class_name StrongholdUpgrade
extends Upgrade


func _init() -> void:
	name = "Stronghold"
	id = "stronghold"
	_max_level = 2
	_category = UpgradeCategory.STRONGHOLD

	SignalBus.register_upgrade.emit(self)
	upgrade_purchased.connect(_on_upgrade_purchased)


func get_cost() -> int:
	return ceil(Scaling.exponential_growth(800, 2.5, _level))


func can_buy() -> bool:
	return not self.is_maxed()
