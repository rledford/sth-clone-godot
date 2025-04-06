class_name RepairmanUpgrade
extends Upgrade

var _enabled = true

func _init() -> void:
	name = "Repairman"
	id = "repairman"
	_category = UpgradeCategory.HEALTH
	priority = 2
	SignalBus.register_upgrade.emit(self)
	level_increased.connect(_on_level_increased)

	SignalBus.stronghold_full.connect(_on_stronghold_full)
	SignalBus.stronghold_vacant.connect(_on_stronghold_vacant)


func _on_stronghold_full():
	self._enabled = false


func _on_stronghold_vacant():
	self._enabled = true


func can_buy() -> bool:
	return _enabled


func get_cost() -> int:
	return 0#(_level * 25) + 50
