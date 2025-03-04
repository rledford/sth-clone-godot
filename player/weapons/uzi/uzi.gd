class_name Uzi
extends Weapon

const Scene = preload("res://player/weapons/uzi/uzi.tscn")

var damage: float = 1
var base_fire_rate: float = 0.05
var reload_time: float = 2

var _magazine: PlayerMagazine
var _state: String = "idle"

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
	_on_event("shoot", point)


func spray(point: Vector2) -> void:
	_on_event("shoot", point)


func reload() -> void:
	_on_event("reload", null)


func get_magazine() -> PlayerMagazine:
	return _magazine


func _shoot(point: Vector2) -> void:
	if not _magazine.has_ammo():
		no_ammo_audio_stream.play()
		return

	shoot_audio_stream.play()
	_magazine.unload(1)

	shoot_area.global_position = point

	var enemies = shoot_area.get_overlapping_bodies()
	if enemies.size() == 0:
		SignalBus.shot_hit_ground.emit(point)
	else:
		enemies.sort_custom(y_sort)
		var enemy = enemies.front()

		if enemy:
			enemy.hit.emit(damage)

	await get_tree().create_timer(base_fire_rate).timeout


func _reload() -> void:
	reload_audio_stream.play()
	await get_tree().create_timer(reload_time).timeout
	_magazine.new_clip()


# Not sure if I can type ctx depending on event, probably not
func _on_event(event: String, ctx) -> void:
	print("sending event ", event)
	assert(event in ["shoot", "reload"])
	if _state != "idle":
		return
	match event:
		"shoot":
			_set_state("shooting")
			await _shoot(ctx)
		"reload":
			_set_state("reloading")
			await _reload()

	_set_state("idle")


func _set_state(state: String) -> void:
	print("setting state to ", state)
	assert(state in ["idle", "shooting", "reloading"])
	_state = state
