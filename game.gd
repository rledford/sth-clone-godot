class_name Game
extends Node2D

const StrongholdScene = preload("res://stronghold/stronghold.tscn")
const scene = preload("res://game.tscn")

@onready var enemy_spawn: EnemySpawn = $EnemySpawn

static func create() -> Game:
	var instance = scene.instantiate()
	return instance

var _hud: HUD
var _state: GameState
var _purse: CoinPurse
var _upgrades: UpgradeSystem
var _upgrade_menu: UpgradeMenu
var _magazine: Magazine
var _stronghold: Stronghold

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_state = GameState.new()
	_purse =  CoinPurse.new()
	_upgrades = UpgradeSystem.new(_purse)
	
	_stronghold = StrongholdScene.instantiate()
	add_child(_stronghold)

	var _waves = Waves.new(enemy_spawn)
	add_child(_waves)

	_magazine = Magazine.new()
	
	var player = Player.create(
		_state.get_health(),
		_state.get_max_health(),
		_magazine
	)

	add_child(player)

	_hud = HUD.create(
		_state.get_health(),
		_state.get_max_health(),
		_magazine.get_ammo(),
		_magazine.get_max_ammo(),
		_purse.get_coins(),
	)
	add_child(_hud)

	_waves.start()

	_upgrade_menu = UpgradeMenu.create(_upgrades)
	_upgrade_menu.hide()
	add_child(_upgrade_menu)

	SignalBus.player_died.connect(_handle_player_died)
	SignalBus.open_upgrade_menu.connect(_handle_open_upgrade_menu)
	SignalBus.close_upgrade_menu.connect(_handle_close_upgrade_menu)

func _handle_player_died() -> void:
	SignalBus.game_over.emit(_state.get_wave())

func _handle_close_upgrade_menu() -> void:
	_upgrade_menu.hide()
	_hud.show()

func _handle_open_upgrade_menu() -> void:
	_hud.hide()
	_upgrade_menu.show()
