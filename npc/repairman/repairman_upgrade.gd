class_name RepairmanUpgrade
extends Upgrade

var _enabled = true


func _init() -> void:
	name = "Repairman"
	id = "repairman"
	_category = UpgradeCategory.HEALTH
	priority = 2
	SignalBus.register_upgrade.emit(self)
	upgrade_purchased.connect(_on_upgrade_purchased)

	SignalBus.stronghold_full.connect(_on_stronghold_full)
	SignalBus.stronghold_vacant.connect(_on_stronghold_vacant)


func _on_stronghold_full():
	self._enabled = false


func _on_stronghold_vacant():
	self._enabled = true


func can_buy() -> bool:
	return _enabled


func get_cost() -> int:
	return (_level * 25) + 50
