class_name Player
extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var shoot_audio_stream: AudioStreamPlayer2D = $ShootAudioStream
@onready var no_ammo_audio_stream: AudioStreamPlayer2D = $NoAmmoAudioStream
@onready var single_bullet_load_stream: AudioStreamPlayer2D = $SingleBulletLoadStream

const scene = preload("res://player/player.tscn")

var damage: float = 1.0
var base_fire_rate: float = 0.2
var fire_rate: float = base_fire_rate
var fire_timer: float = 0.0
var pierce_limit: int = 0

var _is_reloading: bool = false

## The time it takes to reload one bullet
var _reload_time: float = 0.35
var _reload_timer: float = 0.0
var _magazine: Magazine


static func create(magazine: Magazine) -> Player:
	var instance = scene.instantiate()
	instance._magazine = magazine

	return instance


func _ready() -> void:
	FireRateUpgrade.new().level_changed.connect(_handle_fire_rate_upgrade)


func y_sort(a, b) -> bool:
	return a.global_position.y > b.global_position.y


func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	if fire_timer > 0:
		fire_timer -= delta
	if _is_reloading:
		update_reload(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		_handle_shoot()
	elif event.is_action_pressed("reload") and can_reload():
		reload()


func _handle_shoot() -> void:
	if not _magazine.has_ammo():
		no_ammo_audio_stream.play()
		return
	if fire_timer > 0:
		return
	shoot()


func shoot() -> void:
	_is_reloading = false

	shoot_audio_stream.play()
	_magazine.unload(1)
	var enemies = area_2d.get_overlapping_bodies()
	enemies.sort_custom(y_sort)
	for i in range(len(enemies)):
		if enemies[i] is Enemy:
			enemies[i].hit.emit(damage)
		if i >= pierce_limit:
			break

	if not len(enemies):
		SignalBus.shot_hit_ground.emit(global_position)

	fire_timer = fire_rate


func can_reload() -> bool:
	return not _is_reloading and not _magazine.is_full()


func reload() -> void:
	_reload_timer = _reload_time
	_is_reloading = true


func update_reload(delta: float) -> void:
	_reload_timer = max(_reload_timer - delta, 0)
	if _reload_timer > 0:
		return

	_magazine.load(1)
	single_bullet_load_stream.play()

	if _magazine.is_full():
		_is_reloading = false
		return

	_reload_timer = _reload_time


func _handle_fire_rate_upgrade(level: int):
	fire_rate = base_fire_rate - (level * base_fire_rate * 0.1)
