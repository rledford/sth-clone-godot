class_name HUD
extends CanvasLayer

const Scene = preload("res://hud/hud.tscn")

var _init_health: int
var _init_max_health: int

var _init_ammo: int
var _init_max_ammo: int

var _init_coins: int

@onready var bottom_ui: BottomUI = $BottomUI


static func create(health: int, max_health: int, ammo: int, max_ammo: int, coins: int) -> HUD:
	var instance = Scene.instantiate()

	instance._init_health = health
	instance._init_max_health = max_health

	instance._init_ammo = ammo
	instance._init_max_ammo = max_ammo

	instance._init_coins = coins

	return instance


func _ready() -> void:
	bottom_ui.render(_init_health, _init_max_health, _init_ammo, _init_max_ammo, _init_coins)
