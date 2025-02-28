class_name Gunman
extends Node2D

var damage = 1
var _target: Enemy
var _aim_timer: float = 0.0
var _fire_time: float = 0.75
var _fire_timer: float = 0.0

@onready var _collider: CollisionShape2D = $Area2D/CollisionShape2D
@onready var _muzzle_fire_particle: CPUParticles2D = $MuzzleFireParticle
@onready var _gun_shot_sfx: AudioStreamPlayer2D = $GunShotSFX


func _ready() -> void:
	_aim_timer = _rand_aim_time()
	_fire_timer = _fire_time
	_muzzle_fire_particle.emitting = false
	_muzzle_fire_particle.one_shot = true


func _rand_aim_time() -> float:
	return randf_range(0.25, 0.75)


func _is_in_range(a: Node2D) -> bool:
	return (
		global_position.distance_to(a.global_position) <= (_collider.shape as CircleShape2D).radius
	)


func _physics_process(delta: float) -> void:
	_update_target()
	_update_fire(delta)


func _update_fire(delta: float):
	if not _target:
		return

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


func _update_target() -> void:
	if _target:
		rotation = global_position.angle_to_point(_target.global_position)
		return
	var enemies = (get_tree().get_nodes_in_group("enemies") as Array[Enemy]).filter(_is_in_range)
	if len(enemies):
		_target = enemies.pick_random()
		_target.died.connect(_handle_target_died)
		print("[Gunman] Acquired target " + str(_target))


func _handle_target_died() -> void:
	_aim_timer = _rand_aim_time()
	_fire_timer = _fire_time
	_target = null
