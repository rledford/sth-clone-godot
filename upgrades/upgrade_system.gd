class_name UpgradeSystem
extends Resource

var _upgrades: Array[Upgrade]

var _purse: CoinPurse

func _init(purse: CoinPurse) -> void:
	_upgrades = []
	_purse = purse

	SignalBus.register_upgrade.connect(_handle_register_upgrade)
	SignalBus.attempt_upgrade.connect(_handle_attempt_upgrade)

func can_afford(upgrade: Upgrade) -> bool:
	return _purse.get_coins() >= upgrade.getCost()	

func get_upgrades() -> Array[Upgrade]:
	return _upgrades

func _handle_attempt_upgrade(upgrade: Upgrade) -> void:
	if not can_afford(upgrade): return
	
	var cost = upgrade.getCost()

	_purse.spend_coins(cost)
	upgrade.level_increase.emit()

func _handle_register_upgrade(upgrade: Upgrade) -> void:
	_upgrades.append(upgrade)
