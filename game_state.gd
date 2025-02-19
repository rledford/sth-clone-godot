class_name GameState
extends Resource

var _wave: int = 1

var purse: CoinPurse

var _max_health: int = 100
var _health: int = _max_health

var _max_ammo: int = 7
var _ammo = _max_ammo

var _upgrades: UpgradeSystem

func _init() -> void:
	_upgrades = UpgradeSystem.new(self)
	purse = CoinPurse.new()
	
	SignalBus.enemy_died.connect(_handle_enemy_died)

func get_health() -> int:
	return _health

func get_max_health() -> int:
	return _max_health

func get_coins() -> int:
	return purse.get_gold()

func get_wave() -> int:
	return _wave

func get_ammo() -> int:
	return _ammo

func get_max_ammo() -> int:
	return _max_ammo

func get_upgrade_system() -> UpgradeSystem:
	return _upgrades

func _handle_player_died() -> void:
	SignalBus.game_over.emit(_wave, purse.get_gold())

func _handle_enemy_died(reward: int) -> void:
	purse.add(reward)
