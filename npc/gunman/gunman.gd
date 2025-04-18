class_name Gunman
extends Node2D

enum Action { SHOOT, LOOK_FOR_TARGETS, AIM, RELOAD }
const Scene = preload("res://npc/gunman/gunman.tscn")

var damage = 1
var base_thinking_time = 0.25
var shoot_time = 1

var _target: EnemyAlt
var _magazine: Magazine

@onready var _collider: CollisionShape2D = $Area2D/CollisionShape2D
@onready var _muzzle_fire_particle: CPUParticles2D = $MuzzleFireParticle
@onready var _gun_shot_sfx: AudioStreamPlayer2D = $GunShotSFX
@onready var _single_bullet_load_stream: AudioStreamPlayer2D = $SingleBulletLoadStream

static func create() -> Gunman:
	var instance = Scene.instantiate()
	return instance


func _ready() -> void:
	var target_areas = get_tree().get_nodes_in_group("enemy_spawn_areas") as Array[CollisionShape2D]
	var area: CollisionShape2D = target_areas.pick_random()

	self.rotation = self.global_position.angle_to_point(area.global_position)
	_muzzle_fire_particle.one_shot = true
	_muzzle_fire_particle.emitting = false
	_magazine = Magazine.new(2, 2)

	act()


func _physics_process(delta: float) -> void:
	if _target:
		_aim_at(_target, delta)


func act(actions: Array[Action] = []) -> void:
	var action = await think(actions)

	match action:
		Action.SHOOT:
			print("[Gunman] Firing at target")
			await _shoot()
		Action.LOOK_FOR_TARGETS:
			print("[Gunman] Looking for targets")
			_acquire_target()
		Action.AIM:
			print("[Gunman] Aiming at target")
		Action.RELOAD:
			print("[Gunman] Reloading")
			await _reload()

	actions.append(action)
	if actions.size() > 4:
		actions.remove_at(0)

	act(actions)


func think(actions: Array[Action]) -> Action:
	await get_tree().create_timer(_get_thinking_time()).timeout

	if not _magazine.has_ammo():
		return Action.RELOAD

	if _target:
		if not _is_in_sight(_target):
			return Action.AIM
		if _is_in_sight(_target):
			return Action.SHOOT

	var been_looking_a_while = actions.all(func(a): return a == Action.LOOK_FOR_TARGETS)
	if been_looking_a_while and not _magazine.is_full():
		return Action.RELOAD

	return Action.LOOK_FOR_TARGETS


func _get_thinking_time() -> float:
	return base_thinking_time * randf_range(0.9, 1.3)


func _shoot() -> void:
	_muzzle_fire_particle.restart()
	_muzzle_fire_particle.emitting = true
	_gun_shot_sfx.play()
	_magazine.unload(1)
	_target.hit.emit(damage)
	await get_tree().create_timer(shoot_time).timeout


func _reload() -> void:
	while not _magazine.is_full():
		_single_bullet_load_stream.play()
		_magazine.load(1)
		await get_tree().create_timer(1).timeout


func _acquire_target() -> void:
	var enemies = _get_available_targets()
	if len(enemies):
		_target = enemies.pick_random()
		_target.died.connect(_handle_target_died)
		print("[Gunman] Acquired target " + str(_target))


func _aim_at(node: Node, delta: float) -> void:
	var target_rotation = _get_aim_direction(node)
	self.rotation = rotate_toward(self.rotation, target_rotation, delta * 1.8)


func _is_in_sight(node: Node) -> bool:
	var target_rotation = _get_aim_direction(node)
	var aiming_angle = lerp_angle(self.rotation, target_rotation, 1)
	return abs(self.rotation - aiming_angle) < 0.05


func _get_aim_direction(node: Node) -> float:
	return self.global_position.angle_to_point(node.global_position)


func _handle_target_died() -> void:
	print("[Gunman] Target died!")
	_target = null


func _get_available_targets() -> Array[Node]:
	return (get_tree().get_nodes_in_group("enemies")).filter(_is_in_range)


func _is_in_range(a: Node2D) -> bool:
	return (
		global_position.distance_to(a.global_position) <= (_collider.shape as CircleShape2D).radius
	)
