class_name StrongholdUpgrade
extends Upgrade


func _init() -> void:
	name = "Stronghold"
	id = "stronghold"
	_category = UpgradeCategory.WEAPON
	priority = 100

	SignalBus.register_upgrade.emit(self)
	level_increased.connect(_on_level_increased)


func get_cost() -> int:
	return 0


func can_buy() -> bool:
	return true
