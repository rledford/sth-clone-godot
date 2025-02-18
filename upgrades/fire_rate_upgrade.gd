extends Upgrade
class_name FireRateUpgrade


func _init() -> void:
	name = "Fire Rate"
	id = "fire_rate"
	SignalBus.register_upgrade.emit(self)
	level_increase.connect(_on_level_increase)

func getCost() -> int:
	return (_level * 15) + 10
