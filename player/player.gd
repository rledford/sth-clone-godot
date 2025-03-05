class_name Player
extends Node2D

const Scene = preload("res://player/player.tscn")

var _weapon: Weapon


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
	_weapon.point_to(global_position)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		_weapon.pull_trigger()
	elif event.is_action_released("shoot"):
		_weapon.release_trigger()
	elif event.is_action_pressed("reload"):
		_weapon.reload()


# TODO: Need to fix this and the magazine upgrade
func _handle_fire_rate_upgrade(_level: int):
	pass
	# fire_rate = base_fire_rate - (level * base_fire_rate * 0.1)
