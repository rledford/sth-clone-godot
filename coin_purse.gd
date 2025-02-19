extends Resource
class_name CoinPurse

var _coins: int = 0

func get_gold() -> int:
	return _coins

func add(amount: int) -> void:
	print("[Purse] Adding coins: " + str(amount))
	_coins = max(_coins + amount, 0)
	SignalBus.coins_changed.emit(_coins)
