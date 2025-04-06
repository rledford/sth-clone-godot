class_name StrongholdUpgrade
extends Upgrade

var _enabled = true
var _maxed = false

func _init() -> void:
	name = "Stronghold"
	id = "stronghold"
	_category = UpgradeCategory.STRONGHOLD

	SignalBus.register_upgrade.emit(self)
	SignalBus.stronghold_max_level_reached.connect(_on_max_level_reached)
	level_increased.connect(_on_level_increased)


func get_cost() -> int:
	return 0


func can_buy() -> bool:
	return _enabled


func is_maxed() -> bool:
	return self._maxed


func _on_max_level_reached():
	self._enabled = false
	self._maxed = true
