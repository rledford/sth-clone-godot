class_name Uzi
extends Weapon

const Scene = preload("res://player/weapons/uzi/uzi.tscn")
static var weapon_name = "uzi"

var base_damage: float = 1
var base_fire_rate: float = 0.05
var base_reload_time: float = 2
var base_magazine_size: int = 25

var _level: int = 0
var _magazine: PlayerMagazine
var _state: String = "idle"
var _upgrade: UziUpgrade

@onready var shoot_audio_stream: AudioStreamPlayer2D = $ShootAudioStream
@onready var no_ammo_audio_stream: AudioStreamPlayer2D = $NoAmmoAudioStream
@onready var reload_audio_stream: AudioStreamPlayer2D = $ReloadAudioStream
@onready var shoot_area: Area2D = $ShootArea


static func create(upgrade: UziUpgrade) -> Uzi:
	var instance = Scene.instantiate()
	instance._upgrade = upgrade
	return instance


func _ready() -> void:
	_magazine = PlayerMagazine.new(base_magazine_size)
	_upgrade.level_changed.connect(_on_level_changed)


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


func _start_shooting() -> void:
	await _shoot()
	print("Shot once, checking for state ", _state)
	if _state == "shooting":
		_start_shooting()


func _shoot() -> void:
	if not _magazine.has_ammo():
		no_ammo_audio_stream.play()
		await get_tree().create_timer(_get_fire_rate()).timeout
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
			enemy.hit.emit(_get_damage())

	await get_tree().create_timer(_get_fire_rate()).timeout


func _reload() -> void:
	reload_audio_stream.play()
	await get_tree().create_timer(_get_reload_time()).timeout
	_magazine.new_clip()


func _on_level_changed(level: int) -> void:
	_level = level
	_magazine.change_size(_get_clip_size())


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


func _get_damage() -> float:
	return scale_damage(_level)


func _get_fire_rate() -> float:
	return scale_fire_rate(_level)


func _get_clip_size() -> int:
	return scale_clip_size(_level)


func _get_reload_time() -> float:
	return scale_reload_time(_level)


func scale_damage(level: int) -> int:
	return ceil(Scaling.logarithmic_growth(base_damage, 0.5, level))


func scale_fire_rate(level: int) -> float:
	return Scaling.exponential_decay(base_fire_rate, 0.08, level)


func scale_clip_size(level: int) -> int:
	@warning_ignore("INTEGER_DIVISION")
	return base_magazine_size + (level / 2)


func scale_reload_time(level: int) -> float:
	return Scaling.exponential_decay(base_reload_time, 0.1, level)
