class_name Game
extends Node2D

const scene = preload("res://game.tscn")

var wave: int = 1

static func create() -> Game:
	var instance = scene.instantiate()
	return instance

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	SignalBus.player_died.connect(_handle_player_died)
	
	var max_health = 100
	var health = max_health
	
	var max_ammo = 7
	var ammo = max_ammo

	var player = Player.create(health, max_health, ammo, max_ammo)
	add_child(player)

	var hud = HUD.create(health, max_health, ammo, max_ammo)
	add_child(hud)

func _handle_player_died() -> void:
	SignalBus.game_over.emit(wave)
