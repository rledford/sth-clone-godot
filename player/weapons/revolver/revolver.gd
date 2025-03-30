class_name Revolver
extends Weapon

const Scene = preload("res://player/weapons/revolver/revolver.tscn")
static var weapon_name = "revolver"

var base_damage: float = 1.0
var base_fire_rate: float = 0.75
var base_magazine_size: int = 7
var base_reload_time: float = 0.35

var _level: int = 0

var _magazine: Magazine
var _state: String = "idle"
var _upgrade: RevolverUpgrade

@onready var shoot_audio_stream: AudioStreamPlayer2D = $ShootAudioStream
@onready var no_ammo_audio_stream: AudioStreamPlayer2D = $NoAmmoAudioStream
@onready var reload_audio_stream: AudioStreamPlayer2D = $ReloadAudioStream
@onready var shoot_area: Area2D = $ShootArea


static func create() -> Revolver:
	var instance = Scene.instantiate()
	return instance


func _ready() -> void:
	_magazine = Magazine.new(base_magazine_size, base_magazine_size)
	_magazine.ammo_changed.connect(SignalBus.player_ammo_changed.emit)
	_upgrade = RevolverUpgrade.new()

	_upgrade.level_changed.connect(_on_level_changed)

	for i in range(20):
		print_revolver_stats(i)


func point_to(point: Vector2) -> void:
	shoot_area.global_position = point


func pull_trigger() -> void:
	_on_event("pull-trigger")


func release_trigger() -> void:
	_on_event("release-trigger")


func _shoot() -> void:
	if not _magazine.has_ammo():
		no_ammo_audio_stream.play()
		await get_tree().create_timer(_get_fire_rate()).timeout
		return

	shoot_audio_stream.play()
	_magazine.unload(1)

	var enemies = shoot_area.get_overlapping_bodies()
	enemies.sort_custom(y_sort)
	var enemy = enemies.front()

	if enemy:
		enemy.hit.emit(_get_damage())
	else:
		SignalBus.shot_hit_ground.emit(shoot_area.global_position)

	await get_tree().create_timer(_get_fire_rate()).timeout


func get_magazine() -> PlayerMagazine:
	return _magazine


func reload() -> void:
	_on_event("reload")


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


func scale_damage(level: int) -> int:
	return ceil(Scaling.logarithmic_growth(base_damage, 1, level))


func scale_fire_rate(level: int) -> float:
	return Scaling.exponential_decay(base_reload_time, 0.05, level)


func scale_clip_size(level: int) -> int:
	@warning_ignore("INTEGER_DIVISION")
	return base_magazine_size + (level / 5)


func scale_reload_time(level: int) -> float:
	return Scaling.exponential_decay(base_reload_time, 0.08, level)


func get_revolver_stats(level: int) -> Dictionary:
	return {
		"damage": scale_damage(level),
		"fire_rate": scale_fire_rate(level),
		"clip_size": scale_clip_size(level),
		"reload_rate": scale_reload_time(level)
	}


func print_revolver_stats(level: int) -> void:
	print("Level ", level, " revolver stats: ", get_revolver_stats(level))
