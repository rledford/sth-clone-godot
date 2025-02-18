class_name Game
extends Node2D

const scene = preload("res://game.tscn")


static func create() -> Game:
	var instance = scene.instantiate()
	return instance


var _hud: HUD
var _state: GameState

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_state = GameState.new()
	SignalBus.player_died.connect(_handle_player_died)
	SignalBus.open_upgrade_menu.connect(_handle_open_upgrade_menu)
	
	var player = Player.create(
		_state.get_health(),
		_state.get_max_health(),
		_state.get_ammo(),
		_state.get_max_ammo(),
	)

	add_child(player)

	_hud = HUD.create(
		_state.get_health(),
		_state.get_max_health(),
		_state.get_ammo(),
		_state.get_max_ammo(),
		_state.get_coins(),
	)

	add_child(_hud)

func _handle_player_died() -> void:
	SignalBus.game_over.emit(_state.get_wave(), _state.get_coins())


func _handle_open_upgrade_menu() -> void:
	if get_tree().root.has_node("UpgradeMenu"): return
	
	# Creating the menu on the spot here, but it might be better to keep it around and hide/show it when needed?
	var upgrade_menu = UpgradeMenu.create(_state.get_upgrade_system())

	# Not exactly sure if we should be hiding the HUD, we shuffle the menu around to keep it visible, since the information is still relevant
	_hud.hide()
	
	get_tree().root.add_child(upgrade_menu)

	SignalBus.close_upgrade_menu.connect(func(): _hud.show() )
