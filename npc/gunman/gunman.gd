extends Node2D
class_name Gunman

@onready var collider: CollisionShape2D = $Area2D/CollisionShape2D

var _target: Enemy
var damage = 1
var _aim_time: float = 1.0
var _aim_timer: float = 0.0
var _fire_time: float = 1.0
var _fire_timer: float = 0.0

func _ready() -> void:
	_aim_timer = _aim_time
	_fire_timer = _fire_time
	SignalBus.enemy_died.connect(_handle_enemy_died)

func _is_node_closer(a: Node2D, b: Node2D) -> bool:
	return (
		a.global_position.distance_squared_to(global_position) <
		b.global_position.distance_squared_to(global_position)
	)

func _is_in_range(a: Node2D) -> bool:
	return global_position.distance_to(a.global_position) <= (collider.shape as CircleShape2D).radius

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
