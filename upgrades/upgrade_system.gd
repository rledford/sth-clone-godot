class_name UpgradeSystem
extends Resource

## Should be kept sorted
var _upgrades: Array[Upgrade]

var _purse: CoinPurse


func _init(purse: CoinPurse) -> void:
	_upgrades = []
	_purse = purse

	# I'm not sure about the register any more.
	# It's a bit of a code smell and it requires a certain order of initialization
	# Should come up with something a bit more elegant
	# It could be a simple callable instead which will not silently fail at least
	SignalBus.register_upgrade.connect(_handle_register_upgrade)


func can_afford(upgrade: Upgrade) -> bool:
	return _purse.get_coins() >= upgrade.get_cost()


## Returns a sorted list of all upgrades by priority
func get_upgrades() -> Array[Upgrade]:
	return _upgrades


func get_by_id(id: String) -> Upgrade:
	# find_custom is not implemented?

	for upgrade in _upgrades:
		if upgrade.id == id:
			return upgrade
	return null


func attempt_upgrade(upgrade: Upgrade) -> void:
	if not can_afford(upgrade):
		return
	if not upgrade.can_buy():
		return

	var cost = upgrade.get_cost()

	_purse.spend_coins(cost)
	upgrade.level_increased.emit()


func _handle_register_upgrade(upgrade: Upgrade) -> void:
	_upgrades.append(upgrade)
	_upgrades.sort_custom(_sort)


# Returns true if a should come before b
func _sort(a: Upgrade, b: Upgrade) -> bool:
	if a.get_category() == b.get_category():
		return a.priority < b.priority

	return (
		Upgrade.CATEGORY_PRIORITIES[a.get_category()]
		< Upgrade.CATEGORY_PRIORITIES[b.get_category()]
	)
