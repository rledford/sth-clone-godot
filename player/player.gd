class_name Player
extends Node2D

const Scene = preload("res://player/player.tscn")

var _weapon: Weapon

var _fire_rate_upgrade: FireRateUpgrade
var _clip_size_upgrade: ClipSizeUpgrade

var _uzi_upgrade: UziUpgrade


static func create() -> Player:
	var instance = Scene.instantiate()
	return instance


func get_magazine() -> PlayerMagazine:
	return _weapon.get_magazine()


func _ready() -> void:
	_fire_rate_upgrade = FireRateUpgrade.new()
	_clip_size_upgrade = ClipSizeUpgrade.new()
	_uzi_upgrade = UziUpgrade.new()

	_uzi_upgrade.level_increased.connect(_on_uzi_purchase)

	_weapon = Revolver.create(_fire_rate_upgrade, _clip_size_upgrade)
	add_child(_weapon)


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


func _on_uzi_purchase() -> void:
	_weapon.queue_free()
	_weapon = Uzi.create(_fire_rate_upgrade, _clip_size_upgrade)
	add_child(_weapon)
