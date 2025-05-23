class_name Game
extends Node2D

const CursorSmall = preload("res://cursor_16x16.png")
const CursorMed = preload("res://cursor_32x32.png")
const CursorLarge = preload("res://cursor_48x48.png")

const Scene = preload("res://game.tscn")
const StrongholdScene = preload("res://stronghold/stronghold.tscn")

var _window_size: Vector2
var _hud: HUD
var _purse: CoinPurse
var _upgrades: UpgradeSystem
var _upgrade_menu: UpgradeMenu
var _waves: Waves
var _stronghold: Stronghold
var _initial_state: Dictionary = {}
var _player: Player

@onready var enemy_spawn: EnemySpawn = $EnemySpawn


static func create(initial_state: Dictionary = {}) -> Game:
	var instance = Scene.instantiate()
	instance._initial_state = initial_state
	return instance


func _ready() -> void:
	_check_window_resize()

	_purse = CoinPurse.new(_initial_state.get("coins", 0))
	_upgrades = UpgradeSystem.new(_purse, _initial_state.get("upgrades", {}))

	_waves = Waves.new(enemy_spawn, _initial_state.get("cleared_waves", 0))
	add_child(_waves)

	_player = Player.create()
	_stronghold = StrongholdScene.instantiate()

	add_child(_player)
	add_child(_stronghold)

	if _initial_state.has("occupants"):
		_stronghold.restore_occupants(_initial_state.get("occupants", []))

	if _initial_state.has("turrets"):
		_player.restore_turrets(_initial_state.get("turrets", []))

	_hud = (HUD.create(
		_stronghold.get_health().get_health(),
		_stronghold.get_health().get_max_health(),
		_purse.get_coins(),
		_upgrades
	))
	add_child(_hud)

	_waves.start()

	_upgrade_menu = UpgradeMenu.create(_upgrades)
	_upgrade_menu.hide()
	add_child(_upgrade_menu)

	SignalBus.player_died.connect(_on_player_died)
	SignalBus.open_upgrade_menu.connect(_on_open_upgrade_menu)
	SignalBus.close_upgrade_menu.connect(_on_close_upgrade_menu)
	SignalBus.break_started.connect(_on_break_started)
	SignalBus.upgrade_purchased.connect(_on_upgrade_purchased)
	_player.turrets_changed.connect(_report_game_state)


func _on_player_died() -> void:
	SignalBus.game_over.emit(_waves.get_cleared_waves())


func _on_break_started(_break_time: float) -> void:
	_report_game_state()


func _on_upgrade_purchased() -> void:
	_report_game_state()


func _report_game_state() -> void:
	var game_state = {
		"is_running": true,
		"coins": _purse.get_coins(),
		"cleared_waves": _waves.get_cleared_waves(),
		"upgrades": _upgrades.get_upgrade_levels(),
		"occupants": _stronghold.get_occupants(),
		"turrets": _player.get_placed_turrets()
	}

	SignalBus.game_state_changed.emit(game_state)


func _on_close_upgrade_menu() -> void:
	_upgrade_menu.hide()
	_hud.show()


func _on_open_upgrade_menu() -> void:
	_hud.hide()
	_upgrade_menu.show()


func _check_window_resize() -> void:
	var size = DisplayServer.window_get_size()
	var w = size[0]
	var h = size[1]

	if w != _window_size.x or h != _window_size.y:
		print("Window size changed")
		var magic_threshold = 1920
		var max_window_dimension = max(w, h)
		var cursor_res = CursorSmall
		var cursor_hotspot = Vector2(8, 8)

		if max_window_dimension >= magic_threshold:
			cursor_res = CursorMed
			cursor_hotspot = Vector2(16, 16)

		if max_window_dimension >= magic_threshold * 2:
			cursor_res = CursorLarge
			cursor_hotspot = Vector2(24, 24)

		Input.set_custom_mouse_cursor(cursor_res, Input.CursorShape.CURSOR_ARROW, cursor_hotspot)

		_window_size.x = w
		_window_size.y = h

	get_tree().create_timer(0.1).timeout.connect(_check_window_resize)
