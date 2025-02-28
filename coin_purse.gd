extends Resource
class_name CoinPurse

var _coins: int = 0


func _init() -> void:
	SignalBus.enemy_died.connect(_handle_enemy_died)


func get_coins() -> int:
	return _coins


func spend_coins(amount: int) -> void:
	_transact(-amount)


func earn_coins(amount: int) -> void:
	_transact(amount)


func _transact(amount: int) -> void:
	_coins = max(_coins + amount, 0)
	SignalBus.coins_changed.emit(_coins)
	print("[Purse] Transaction: " + str(amount) + ". Balance: " + str(_coins))


func _handle_enemy_died(reward: int) -> void:
	earn_coins(reward)
