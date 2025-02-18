extends Upgrade
class_name ClipSizeUpgrade


func _init() -> void:
	name = "Clip Size"
	id = "clip_size"
	SignalBus.register_upgrade.emit(self)
	level_increase.connect(_on_level_increase)

func getCost() -> int:
	return (_level * 10) + 10
