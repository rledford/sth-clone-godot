class_name ClipSizeUpgrade
extends Upgrade


func _init() -> void:
	name = "Clip Size"
	id = "clip_size"
	_category = UpgradeCategory.MAGAZINE
	priority = 1

	SignalBus.register_upgrade.emit(self)
	level_increased.connect(_on_level_increased)


func get_cost() -> int:
	return (_level * 10) + 10
