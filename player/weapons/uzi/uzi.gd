class_name Uzi
extends Weapon

const Scene = preload("res://player/weapons/uzi/uzi.tscn")

var damage: float = 1
var base_fire_rate: float = 0.05
var reload_time: float = 2

var _magazine: PlayerMagazine
var _state: String = "idle"

var _fire_rate_upgrade: FireRateUpgrade
var _clip_size_upgrade: ClipSizeUpgrade

@onready var shoot_audio_stream: AudioStreamPlayer2D = $ShootAudioStream
@onready var no_ammo_audio_stream: AudioStreamPlayer2D = $NoAmmoAudioStream
@onready var reload_audio_stream: AudioStreamPlayer2D = $ReloadAudioStream
@onready var shoot_area: Area2D = $ShootArea


static func create(fire_rate_upgrade: FireRateUpgrade, clip_size_upgrade: ClipSizeUpgrade) -> Uzi:
	var instance = Scene.instantiate()
	instance._fire_rate_upgrade = fire_rate_upgrade
	instance._clip_size_upgrade = clip_size_upgrade
	return instance


func _ready() -> void:
	_magazine = PlayerMagazine.new(25, _clip_size_upgrade, 0.5)


func point_to(point: Vector2) -> void:
	shoot_area.global_position = point


func pull_trigger() -> void:
	_on_event("pull-trigger")


func release_trigger() -> void:
	_on_event("release-trigger")


func reload() -> void:
	_on_event("reload")


func get_magazine() -> PlayerMagazine:
	return _magazine


func get_fire_rate() -> float:
	return base_fire_rate - (_fire_rate_upgrade.get_level() * base_fire_rate * 0.1)


func _start_shooting() -> void:
	await _shoot()
	print("Shot once, checking for state ", _state)
	if _state == "shooting":
		_start_shooting()


func _shoot() -> void:
	if not _magazine.has_ammo():
		no_ammo_audio_stream.play()
		await get_tree().create_timer(base_fire_rate).timeout
		return

	shoot_audio_stream.play()
	_magazine.unload(1)

	var enemies = shoot_area.get_overlapping_bodies()
	if enemies.size() == 0:
		SignalBus.shot_hit_ground.emit(shoot_area.global_position)
	else:
		enemies.sort_custom(y_sort)
		var enemy = enemies.front()

		if enemy:
			enemy.hit.emit(damage)

	await get_tree().create_timer(get_fire_rate()).timeout


func _reload() -> void:
	reload_audio_stream.play()
	await get_tree().create_timer(reload_time).timeout
	_magazine.new_clip()


func _on_event(event: String) -> void:
	print("sending event ", event)
	assert(event in ["pull-trigger", "release-trigger", "reload"])

	match event:
		"pull-trigger":
			if _state != "idle":
				return
			_set_state("shooting")
			_start_shooting()
		"release-trigger":
			_set_state("idle")
		"reload":
			_set_state("reloading")
			await _reload()
			_set_state("idle")


func _set_state(state: String) -> void:
	print("setting state to ", state)
	assert(state in ["idle", "shooting", "reloading"])
	_state = state
