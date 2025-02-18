class_name Player
extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var shoot_audio_stream: AudioStreamPlayer2D = $ShootAudioStream
@onready var no_ammo_audio_stream: AudioStreamPlayer2D = $NoAmmoAudioStream
@onready var single_bullet_load_stream: AudioStreamPlayer2D = $SingleBulletLoadStream

const scene = preload("res://player/player.tscn")

var damage: float = 1.0
var fire_rate: float = 0.1
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

func y_sort(a, b) -> bool:
	return a.global_position.y > b.global_position.y

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	if fire_timer > 0:
		fire_timer -= delta
	if _is_reloading:
		update_reload(delta)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		if can_shoot():
			shoot()
		else:
			no_ammo_audio_stream.play()
	elif Input.is_action_just_pressed("reload") and can_reload():
		reload()

func can_shoot() -> bool:
	return _ammo > 0 and fire_timer <= 0
	
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
