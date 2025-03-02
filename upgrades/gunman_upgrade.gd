class_name GunmanUpgrade
extends Upgrade


func _init() -> void:
	name = "Gunman"
	id = "gunman"
	SignalBus.register_upgrade.emit(self)
	level_increased.connect(_on_level_increased)


func get_cost() -> int:
	return (_level * 50) + 100
