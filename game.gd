class_name Game
extends Node2D

const CursorSmall = preload("res://cursor_16x16.png")
const CursorMed = preload("res://cursor_32x32.png")
const CursorLarge = preload("res://cursor_48x48.png")

const Scene = preload("res://game.tscn")
const Stronghold = preload("res://stronghold/stronghold.tscn")

var _window_size: Vector2
var _hud: HUD
var _purse: CoinPurse
var _upgrades: UpgradeSystem
var _upgrade_menu: UpgradeMenu
var _waves: Waves
@onready var enemy_spawn: EnemySpawn = $EnemySpawn


static func create() -> Game:
	var instance = Scene.instantiate()
	return instance


func _ready() -> void:
	_check_window_resize()
	_purse = CoinPurse.new()
	_upgrades = UpgradeSystem.new(_purse)
	_waves = Waves.new(enemy_spawn)
	add_child(_waves)

	var player = Player.create()

	add_child(player)
	add_child(Stronghold.instantiate())

	_hud = (HUD.create(
		100,
		100,
		_purse.get_coins(),
		_upgrades
	))
	add_child(_hud)

	_waves.start()

	_upgrade_menu = UpgradeMenu.create(_upgrades)
	_upgrade_menu.hide()
	add_child(_upgrade_menu)

	SignalBus.player_died.connect(_handle_player_died)
	SignalBus.open_upgrade_menu.connect(_handle_open_upgrade_menu)
	SignalBus.close_upgrade_menu.connect(_handle_close_upgrade_menu)


func _handle_player_died() -> void:
	SignalBus.game_over.emit(_waves.get_wave())


func _handle_close_upgrade_menu() -> void:
	_upgrade_menu.hide()
	_hud.show()


func _handle_open_upgrade_menu() -> void:
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
