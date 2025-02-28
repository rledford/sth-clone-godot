class_name Gunman
extends Node2D

const Scene = preload("res://npc/gunman/gunman.tscn")

var damage = 1
var _target: Enemy
var _aim_timer: float = 0.0
var _fire_time: float = 0.75
var _fire_timer: float = 0.0

@onready var _collider: CollisionShape2D = $Area2D/CollisionShape2D
@onready var _muzzle_fire_particle: CPUParticles2D = $MuzzleFireParticle
@onready var _gun_shot_sfx: AudioStreamPlayer2D = $GunShotSFX


static func create() -> Gunman:
	var instance = Scene.instantiate()
	return instance


func _ready() -> void:
	_aim_timer = _rand_aim_time()
	_fire_timer = _fire_time
	_muzzle_fire_particle.emitting = false
	_muzzle_fire_particle.one_shot = true


func _physics_process(delta: float) -> void:
	if not _target:
		return _acquire_target()

	if not _is_in_sight(_target):
		return _aim_at(_target, delta)

	if _is_in_sight(_target):
		_aim_timer = max(_aim_timer - delta, 0)
		if _aim_timer > 0:
			return

		_fire_timer = max(_fire_timer - delta, 0)
		if _fire_timer <= 0:
			_fire_timer = _fire_time
			_muzzle_fire_particle.restart()
			_muzzle_fire_particle.emitting = true
			_gun_shot_sfx.play()
			_target.hit.emit(damage)


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
	_aim_timer = _rand_aim_time()
	_fire_timer = _fire_time
	_target = null


func _get_available_targets() -> Array[Node]:
	return (get_tree().get_nodes_in_group("enemies")).filter(_is_in_range)


func _rand_aim_time() -> float:
	return randf_range(0.25, 0.75)


func _is_in_range(a: Node2D) -> bool:
	return (
		global_position.distance_to(a.global_position) <= (_collider.shape as CircleShape2D).radius
	)
