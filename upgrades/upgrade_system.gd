class_name UpgradeSystem
extends Resource

var _upgrades: Array

var _state: GameState

func _init(state) -> void:
	_upgrades = []
	_state = state

	SignalBus.register_upgrade.connect(_handle_register_upgrade)
	SignalBus.attempt_upgrade.connect(_handle_attempt_upgrade)

func can_afford(upgrade: Upgrade) -> bool:
	return _state.get_coins() >= upgrade.getCost()	

func get_upgrades() -> Array:
	return _upgrades

func _handle_attempt_upgrade(upgrade: Upgrade) -> void:
	if not can_afford(upgrade): return
	
	var cost = upgrade.getCost()

	_state.decrease_coins.emit(cost)

	upgrade.level_increase.emit()

func _handle_register_upgrade(upgrade: Upgrade) -> void:
	_upgrades.append(upgrade)
