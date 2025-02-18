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

var _max_health: int
var _health: int
var _ammo: int
var _max_ammo: int

var _is_reloading: bool = false
var _reload_time: float = 2.5
var _reload_timer: float = 0.0

static func create(health: int, max_health: int, ammo: int, max_ammo: int) -> Player:
	var instance = scene.instantiate()
	instance._max_health = max_health
	instance._health = health
	instance._ammo = ammo
	instance._max_ammo = max_ammo
	
	return instance

func _ready() -> void:
	SignalBus.player_hit.connect(_handle_player_hit)

	ClipSizeUpgrade.new().level_change.connect(_handle_clip_size_upgrade)
	FireRateUpgrade.new().level_change.connect(_handle_fire_rate_upgrade)


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
	if _ammo < 0:
		no_ammo_audio_stream.play()
		return
	if fire_timer > 0:
		return
	shoot()
	
func shoot() -> void:
	_is_reloading = false
	
	shoot_audio_stream.play()
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
	
	var new_ammo = _ammo - 1
	_ammo = new_ammo
	
	SignalBus.player_ammo_changed.emit(_ammo, _max_ammo)

func can_reload() -> bool:
	return not _is_reloading and _ammo < _max_ammo

func reload() -> void:
	var ammo_remaining_perc = float(_ammo) / float(_max_ammo)
	_reload_timer = _reload_time - (_reload_time * ammo_remaining_perc)
	_is_reloading = true

func update_reload(delta: float) -> void:
	_reload_timer = max(_reload_timer - delta, 0)
	
	var new_ammo = floor(_max_ammo * ((_reload_time - _reload_timer) / _reload_time))
	
	if new_ammo > _ammo:
		single_bullet_load_stream.play()
	
	_ammo = new_ammo
	SignalBus.player_ammo_changed.emit(new_ammo, _max_ammo)
	
	if _reload_timer <= 0:
		_is_reloading = false

func _handle_player_hit(amount: int) -> void:
	var new_health = max(_health - amount, 0)
	_health = new_health
	
	SignalBus.player_health_changed.emit(new_health, _max_health)
	
	if(new_health == 0):
		SignalBus.player_died.emit()

# These would probably be simpler if we create gun and magazine classes
func _handle_clip_size_upgrade(level: int):
	_max_ammo = 7 + level
	SignalBus.player_ammo_changed.emit(_ammo, _max_ammo)

func _handle_fire_rate_upgrade(level: int):
	fire_rate =  base_fire_rate - (level * base_fire_rate * 0.1)
