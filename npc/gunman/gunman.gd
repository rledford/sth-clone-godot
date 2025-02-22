extends Node2D
class_name Gunman

@onready var _collider: CollisionShape2D = $Area2D/CollisionShape2D
@onready var _muzzle_fire_particle: CPUParticles2D = $MuzzleFireParticle
@onready var gun_shot_sfx: AudioStreamPlayer2D = $GunShotSFX

var _target: Enemy
var damage = 1
var _aim_time: float = 1.0
var _aim_timer: float = 0.0
var _fire_time: float = 2.5
var _fire_timer: float = 0.0

func _ready() -> void:
	SignalBus.enemy_died.connect(_handle_enemy_died)
	
	_aim_timer = _aim_time
	_fire_timer = _fire_time
	_muzzle_fire_particle.emitting = false
	_muzzle_fire_particle.one_shot = true

func _is_node_closer(a: Node2D, b: Node2D) -> bool:
	return (
		a.global_position.distance_squared_to(global_position) <
		b.global_position.distance_squared_to(global_position)
	)

func _is_in_range(a: Node2D) -> bool:
	return global_position.distance_to(a.global_position) <= (_collider.shape as CircleShape2D).radius

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
		_muzzle_fire_particle.rotation = global_position.angle_to_point(_target.global_position) - deg_to_rad(90.0)
		_muzzle_fire_particle.restart()
		_muzzle_fire_particle.emitting = true
		gun_shot_sfx.play()
		_target.hit.emit(damage)

func _update_target() -> void:
	if _target:
		return
	var enemies = (get_tree().get_nodes_in_group("enemy") as Array[Enemy]).filter(_is_in_range)
	if len(enemies):
		_target = enemies.pick_random()
		print("[Gunman] Acquired target " + str(_target))

func _handle_enemy_died(enemy: Enemy, _reward: int) -> void:
	if enemy == _target:
		_aim_timer = _aim_time
		_fire_timer = _fire_time
		_target = null
