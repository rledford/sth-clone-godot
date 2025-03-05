class_name Revolver
extends Weapon

const Scene = preload("res://player/weapons/revolver/revolver.tscn")

var damage: float = 1.0
var base_fire_rate: float = 0.75
var reload_time: float = 0.35

var _magazine: PlayerMagazine
var _is_reloading: bool = false
var _is_shooting: bool = false

var _is_trigger_pulled: bool = false

@onready var shoot_audio_stream: AudioStreamPlayer2D = $ShootAudioStream
@onready var no_ammo_audio_stream: AudioStreamPlayer2D = $NoAmmoAudioStream
@onready var reload_audio_stream: AudioStreamPlayer2D = $ReloadAudioStream
@onready var shoot_area: Area2D = $ShootArea


static func create() -> Revolver:
	var instance = Scene.instantiate()
	return instance


func _ready() -> void:
	_magazine = PlayerMagazine.new(7)


func point_to(point: Vector2) -> void:
	shoot_area.global_position = point


func pull_trigger() -> void:
	if not _is_trigger_pulled:
		_is_trigger_pulled = true
		_shoot()


func release_trigger() -> void:
	_is_trigger_pulled = false


func _shoot() -> void:
	if not _magazine.has_ammo():
		no_ammo_audio_stream.play()
		return

	if _is_shooting:
		return

	_is_reloading = false
	_is_shooting = true

	shoot_audio_stream.play()
	_magazine.unload(1)

	var enemies = shoot_area.get_overlapping_bodies()
	enemies.sort_custom(y_sort)
	var enemy = enemies.front()

	if enemy:
		enemy.hit.emit(damage)
	else:
		SignalBus.shot_hit_ground.emit(shoot_area.global_position)

	await get_tree().create_timer(base_fire_rate).timeout
	_is_shooting = false


func get_magazine() -> PlayerMagazine:
	return _magazine


func reload() -> void:
	if _magazine.is_full():
		_is_reloading = false
		return

	_is_reloading = true

	_magazine.load(1)
	reload_audio_stream.play()

	await get_tree().create_timer(reload_time).timeout

	if _is_reloading:
		reload()
