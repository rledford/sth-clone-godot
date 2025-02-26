class_name GunmanUpgrade
extends Upgrade


func _init() -> void:
	name = "Gunman"
	id = "gunman"
	SignalBus.register_upgrade.emit(self)
	level_increased.connect(_on_level_increased)

func getCost() -> int:
	return (_level * 25) + 50
