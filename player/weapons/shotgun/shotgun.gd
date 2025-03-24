class_name Shotgun
extends Weapon

const Scene = preload("res://player/weapons/shotgun/shotgun.tscn")
static var weapon_name = "shotgun"

var damage: float = 1
var base_fire_rate: float = 0.75
var reload_time: float = 0.75
var base_magazine_size: int = 2
var pellet_count: int = 6
var max_spread: float = 30

var _magazine: PlayerMagazine
var _state: String = "idle"

var _fire_rate_upgrade: FireRateUpgrade
var _clip_size_upgrade: ClipSizeUpgrade
var _shoot_areas: Array[Area2D] = []
var _cursor_position: Vector2 = Vector2(0, 0)

@onready var shoot_audio_stream: AudioStreamPlayer2D = $ShootAudioStream
@onready var no_ammo_audio_stream: AudioStreamPlayer2D = $NoAmmoAudioStream
@onready var reload_audio_stream: AudioStreamPlayer2D = $ReloadAudioStream
# This gets duplicated and deleted when the weapon is created
@onready var shoot_area: Area2D = $ShootArea


static func create(
	fire_rate_upgrade: FireRateUpgrade, clip_size_upgrade: ClipSizeUpgrade
) -> Shotgun:
	var instance = Scene.instantiate()
	instance._fire_rate_upgrade = fire_rate_upgrade
	instance._clip_size_upgrade = clip_size_upgrade
	return instance


func _ready() -> void:
	_magazine = PlayerMagazine.new(base_magazine_size, _clip_size_upgrade, 1)

	for _i in range(pellet_count):
		var area = shoot_area.duplicate()
		_shoot_areas.append(area)
		add_child(area)

	shoot_area.queue_free()


func point_to(point: Vector2) -> void:
	_cursor_position = point


func pull_trigger() -> void:
	_on_event("pull-trigger")


func release_trigger() -> void:
	_on_event("release-trigger")


func get_magazine() -> PlayerMagazine:
	return _magazine


func get_fire_rate() -> float:
	return base_fire_rate - (_fire_rate_upgrade.get_level() * base_fire_rate * 0.1)


func reload() -> void:
	_on_event("reload")


func _shoot() -> void:
	if not _magazine.has_ammo():
		no_ammo_audio_stream.play()
		await get_tree().create_timer(base_fire_rate).timeout
		return

	shoot_audio_stream.play()
	_magazine.unload(1)

	_spread(_cursor_position)
	await get_tree().physics_frame

	for area in _shoot_areas:
		var enemies = area.get_overlapping_bodies()
		enemies.sort_custom(y_sort)
		var enemy = enemies.front()

		if enemy:
			enemy.hit.emit(damage)
		else:
			SignalBus.shot_hit_ground.emit(area.global_position)

	await get_tree().create_timer(get_fire_rate()).timeout


func _spread(from: Vector2) -> void:
	for area in _shoot_areas:
		var offset = Vector2(
			randf_range(-max_spread, max_spread), randf_range(-max_spread, max_spread)
		)
		var end = from + offset
		area.global_position = end


func _reload() -> void:
	if _magazine.is_full():
		_on_event("finish_reloading")
		return

	_magazine.load(1)
	reload_audio_stream.play()

	await get_tree().create_timer(reload_time).timeout
	if _state == "reloading":
		_reload()


func _on_event(event: String) -> void:
	print("sending event ", event)
	assert(event in ["pull-trigger", "release-trigger", "reload", "finish_reloading"])

	match event:
		"pull-trigger":
			if _state != "idle":
				return
			_set_state("shooting")
			await _shoot()
		"release-trigger":
			_set_state("idle")
		"reload":
			if _state != "idle":
				return
			_set_state("reloading")
			await _reload()

		"finish_reloading":
			_set_state("idle")


func _set_state(state: String) -> void:
	print("setting state to ", state)
	assert(state in ["idle", "shooting", "reloading"])
	_state = state
