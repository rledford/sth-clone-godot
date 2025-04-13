class_name RevolverUpgrade
extends Upgrade


func _init() -> void:
	name = "Revolver"
	id = "revolver"
	_category = UpgradeCategory.WEAPON
	priority = 2

	SignalBus.register_upgrade.emit(self)
	upgrade_purchased.connect(_on_upgrade_purchased)


func get_cost() -> int:
	return ceil(Scaling.exponential_growth(15, 1.5, _level))


func get_label() -> String:
	return name + " " + str(_level + 1)
