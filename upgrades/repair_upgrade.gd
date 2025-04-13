class_name RepairUpgrade
extends Upgrade

var _health: Health


func _init(health: Health) -> void:
	name = "Repair"
	id = "repair"
	_category = UpgradeCategory.HEALTH
	priority = 1
	_health = health

	SignalBus.register_upgrade.emit(self)
	upgrade_purchased.connect(_on_upgrade_purchased)


func can_buy() -> bool:
	return not _health.is_full()


func get_label() -> String:
	return name


func get_cost() -> int:
	return 20
