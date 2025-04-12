class_name CoinPurse
extends Resource

var _coins: int = 0


func _init(initial_coins: int = 0) -> void:
	_coins = max(initial_coins, 0)
	if initial_coins > 0:
		print("[Purse] Initialized with: " + str(_coins) + " coins")

	SignalBus.enemy_died.connect(_handle_enemy_died)
	SignalBus.coins_changed.emit(_coins)


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
