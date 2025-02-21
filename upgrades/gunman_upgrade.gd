extends Upgrade
class_name GunmanUpgrade


func _init() -> void:
	name = "Gunman"
	id = "gunman"
	SignalBus.register_upgrade.emit(self)
	level_increase.connect(_on_level_increase)

func getCost() -> int:
	return 0
	# return (_level * 10) + 100
