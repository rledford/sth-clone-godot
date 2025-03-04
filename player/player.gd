class_name Player
extends Node2D

const Scene = preload("res://player/player.tscn")

var _weapon: Weapon

var _is_shooting: bool = false


static func create() -> Player:
	var instance = Scene.instantiate()
	# instance._weapon = Revolver.create()
	instance._weapon = Uzi.create()

	return instance


func get_magazine() -> PlayerMagazine:
	return _weapon.get_magazine()


func _ready() -> void:
	add_child(_weapon)
	FireRateUpgrade.new().level_changed.connect(_handle_fire_rate_upgrade)


func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()

	if _is_shooting:
		_weapon.spray(global_position)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		_is_shooting = true
		_weapon.start_shooting(global_position)
	elif event.is_action_released("shoot"):
		_is_shooting = false
		_weapon.stop_shooting()
	elif event.is_action_pressed("reload"):
		_weapon.reload()


# TODO: Need to fix this and the magazine upgrade
func _handle_fire_rate_upgrade(_level: int):
	pass
	# fire_rate = base_fire_rate - (level * base_fire_rate * 0.1)
