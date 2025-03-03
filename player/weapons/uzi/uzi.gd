class_name Uzi
extends Weapon

const Scene = preload("res://player/weapons/uzi/uzi.tscn")

var damage: float = 0.5
var base_fire_rate: float = 0.05
var reload_time: float = 2

var _magazine: PlayerMagazine
var _is_reloading: bool = false
var _is_shooting: bool = false

@onready var shoot_audio_stream: AudioStreamPlayer2D = $ShootAudioStream
@onready var no_ammo_audio_stream: AudioStreamPlayer2D = $NoAmmoAudioStream
@onready var reload_audio_stream: AudioStreamPlayer2D = $ReloadAudioStream
@onready var shoot_area: Area2D = $ShootArea


static func create() -> Uzi:
	var instance = Scene.instantiate()
	return instance


func _ready() -> void:
	_magazine = PlayerMagazine.new(25)


func start_shooting(point: Vector2) -> void:
	_shoot(point)


func spray(point: Vector2) -> void:
	_shoot(point)


func reload() -> void:
	if _magazine.is_full():
		_is_reloading = false
		return

	if _is_reloading:
		return

	_is_reloading = true

	reload_audio_stream.play()
	await get_tree().create_timer(reload_time).timeout

	_magazine.new_clip()
	_is_reloading = false


func get_magazine() -> PlayerMagazine:
	return _magazine


func _shoot(point: Vector2) -> void:
	if not _magazine.has_ammo():
		no_ammo_audio_stream.play()
		return

	if _is_shooting:
		return

	_is_reloading = false
	_is_shooting = true

	shoot_audio_stream.play()
	_magazine.unload(1)

	shoot_area.global_position = point

	var enemies = shoot_area.get_overlapping_bodies()
	enemies.sort_custom(y_sort)
	var enemy = enemies.front()

	if enemy:
		enemy.hit.emit(damage)
	else:
		SignalBus.shot_hit_ground.emit(point)

	await get_tree().create_timer(base_fire_rate).timeout
	_is_shooting = false
