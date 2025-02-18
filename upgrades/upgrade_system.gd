class_name UpgradeSystem
extends Resource

var _upgrades = UpgradeDefinition.get_all()

func _create_upgrade_levels(upgrades)->Dictionary:
	var result: Dictionary = {}
	for upgrade in upgrades:
		result[upgrade.id] = 0
	return result

var _upgrade_levels: Dictionary

var _state: GameState

func _init(state) -> void:
	_upgrade_levels = _create_upgrade_levels(_upgrades)
	_state = state

	SignalBus.attempt_upgrade.connect(_handle_attempt_upgrade)

func can_afford(upgrade: UpgradeDefinition) -> bool:
	return _state.get_coins() >= upgrade.cost

func _handle_attempt_upgrade(upgrade: UpgradeDefinition) -> void:
	if not can_afford(upgrade): return

	_state.decrease_coins.emit(upgrade.cost)
	_upgrade_levels[upgrade.id] += 1

	SignalBus.upgrade_purchased.emit(upgrade.id, _upgrade_levels[upgrade.id])
