class_name GunmanUpgrade
extends Upgrade

var _enabled: bool = true


func _init() -> void:
	name = "Gunman"
	id = "gunman"
	SignalBus.register_upgrade.emit(self)
	level_increased.connect(_on_level_increased)

	SignalBus.stronghold_full.connect(_on_stronghold_full)
	SignalBus.stronghold_vacant.connect(_on_stronghold_vacant)


func can_buy() -> bool:
	return _enabled


func _on_stronghold_full():
	self._enabled = false


func _on_stronghold_vacant():
	self._enabled = true


func get_cost() -> int:
	return 0  #(_level * 50) + 100
