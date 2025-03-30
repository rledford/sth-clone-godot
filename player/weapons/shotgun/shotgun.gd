class_name Shotgun
extends Weapon

const Scene = preload("res://player/weapons/shotgun/shotgun.tscn")
static var weapon_name = "shotgun"

var base_damage: float = 1
var base_fire_rate: float = 0.75
var base_reload_time: float = 0.75
var base_magazine_size: int = 2
var base_pellet_count: int = 6
var max_spread: float = 30

var _level: int = 0
var _magazine: Magazine
var _state: String = "idle"
var _upgrade: ShotgunUpgrade

var _shoot_areas: Array[Area2D] = []
var _cursor_position: Vector2 = Vector2(0, 0)

@onready var shoot_audio_stream: AudioStreamPlayer2D = $ShootAudioStream
@onready var no_ammo_audio_stream: AudioStreamPlayer2D = $NoAmmoAudioStream
@onready var reload_audio_stream: AudioStreamPlayer2D = $ReloadAudioStream
# This gets duplicated and deleted when the weapon is created
@onready var shoot_area: Area2D = $ShootArea


static func create(
	upgrade: ShotgunUpgrade,
) -> Shotgun:
	var instance = Scene.instantiate()
	instance._upgrade = upgrade
	return instance


func _ready() -> void:
	_magazine = Magazine.new(base_magazine_size, base_magazine_size)
	_magazine.ammo_changed.connect(SignalBus.player_ammo_changed.emit)
	_upgrade.level_changed.connect(_on_level_changed)

	_update_shoot_areas()


func _update_shoot_areas() -> void:
	var target = _get_pellet_count()
	var missing = target - len(_shoot_areas)
	if missing > 0:
		for _i in range(missing):
			var area = shoot_area.duplicate()
			_shoot_areas.append(area)
			add_child(area)


func point_to(point: Vector2) -> void:
	_cursor_position = point


func pull_trigger() -> void:
	_on_event("pull-trigger")


func release_trigger() -> void:
	_on_event("release-trigger")


func get_magazine() -> PlayerMagazine:
	return _magazine


func reload() -> void:
	_on_event("reload")


func _shoot() -> void:
	if not _magazine.has_ammo():
		no_ammo_audio_stream.play()
		await get_tree().create_timer(_get_fire_rate()).timeout
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
			enemy.hit.emit(_get_damage())
		else:
			SignalBus.shot_hit_ground.emit(area.global_position)

	await get_tree().create_timer(_get_fire_rate()).timeout


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

	await get_tree().create_timer(_get_reload_time()).timeout
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


func _on_level_changed(level: int) -> void:
	_level = level
	_magazine.change_size(_get_clip_size())


func _get_damage() -> float:
	return scale_damage(_level)


func _get_fire_rate() -> float:
	return scale_fire_rate(_level)


func _get_clip_size() -> int:
	return scale_clip_size(_level)


func _get_reload_time() -> float:
	return scale_reload_time(_level)


func _get_pellet_count() -> int:
	return scale_pellet_count(_level)


func scale_damage(level: int) -> int:
	return ceil(Scaling.logarithmic_growth(base_damage, 0.5, level))


func scale_pellet_count(level: int) -> int:
	return ceil(Scaling.logarithmic_growth(base_pellet_count, 0.5, level))


func scale_fire_rate(level: int) -> float:
	return Scaling.exponential_decay(base_reload_time, 0.05, level)


func scale_clip_size(level: int) -> int:
	@warning_ignore("INTEGER_DIVISION")
	return base_magazine_size + (level / 6)


func scale_reload_time(level: int) -> float:
	return Scaling.exponential_decay(base_reload_time, 0.10, level)
