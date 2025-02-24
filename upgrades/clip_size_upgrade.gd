class_name ClipSizeUpgrade
extends Upgrade


func _init() -> void:
	name = "Clip Size"
	id = "clip_size"
	SignalBus.register_upgrade.emit(self)
	level_increased.connect(_on_level_increase)


func get_cost() -> int:
	return (_level * 10) + 10
