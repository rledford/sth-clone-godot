class_name FireRateUpgrade
extends Upgrade


func _init() -> void:
	name = "Fire Rate"
	id = "fire_rate"
	SignalBus.register_upgrade.emit(self)
	level_increased.connect(_on_level_increase)


func get_cost() -> int:
	return (_level * 15) + 10
