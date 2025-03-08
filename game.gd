class_name Game
extends Node2D

const cursor_small = preload("res://cursor_16x16.png")
const cursor_med = preload("res://cursor_32x32.png")
const cursor_large = preload("res://cursor_48x48.png")

const StrongholdScene = preload("res://stronghold/stronghold.tscn")
const Scene = preload("res://game.tscn")

var _window_size: Vector2
var _hud: HUD
var _purse: CoinPurse
var _upgrades: UpgradeSystem
var _upgrade_menu: UpgradeMenu
var _magazine: Magazine
var _waves: Waves
var _stronghold: Stronghold
@onready var enemy_spawn: EnemySpawn = $EnemySpawn


static func create() -> Game:
	var instance = Scene.instantiate()
	return instance


func _ready() -> void:
	# Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_check_window_resize()
	_purse = CoinPurse.new()
	_upgrades = UpgradeSystem.new(_purse)

	_stronghold = StrongholdScene.instantiate()
	add_child(_stronghold)

	_waves = Waves.new(enemy_spawn)
	add_child(_waves)

	_magazine = PlayerMagazine.new(7, 7)

	var player = Player.create(_magazine)

	add_child(player)

	_hud = (
		HUD
		. create(
			_stronghold.get_health().get_health(),
			_stronghold.get_health().get_max_health(),
			_magazine.get_ammo(),
			_magazine.get_max_ammo(),
			_purse.get_coins(),
		)
	)
	add_child(_hud)

	_waves.start()

	_upgrade_menu = UpgradeMenu.create(_upgrades)
	_upgrade_menu.hide()
	add_child(_upgrade_menu)

	SignalBus.player_died.connect(_handle_player_died)
	SignalBus.open_upgrade_menu.connect(_handle_open_upgrade_menu)
	#SignalBus.close_upgrade_menu.connect(_handle_close_upgrade_menu)


func _handle_player_died() -> void:
	SignalBus.game_over.emit(_waves.get_wave())


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
		var cursor_res = cursor_small
		var cusrot_hotspot = Vector2(8, 8)

		if max_window_dimension >= magic_threshold:
			cursor_res = cursor_med
			cusrot_hotspot = Vector2(16, 16)

		if max_window_dimension >= magic_threshold * 2:
			cursor_res = cursor_large
			cusrot_hotspot = Vector2(24, 24)

		Input.set_custom_mouse_cursor(cursor_res, 0, cusrot_hotspot)

		_window_size.x = w
		_window_size.y = h

	await get_tree().create_timer(0.1).timeout.connect(_check_window_resize)
