extends Node2D

@export var fire_rate: float = 0.5
@export var max_shots: int = 100

@onready var _collider: CollisionShape2D = $Area2D/CollisionShape2D

var _shots_remaining = 0
var _last_fire_time = 0
var _target: EnemyAlt

func _ready():
	self._shots_remaining = max_shots


func _physics_process(delta: float) -> void:
	if not self._target:
		_acquire_target()
		return
	
	_aim(delta)
	
	if _can_fire():
		_fire()


func _acquire_target() -> void:
	self._target = (get_tree().get_nodes_in_group("enemies")).reduce(
		func (acc, cur):
			if not _is_in_range(cur):
				return acc

			if not acc:
				return cur

			self._target = _closest_enemy(acc, cur)
	)

	if self._target:
		self._target.died.connect(self._on_target_died)


func _is_in_range(node: Node2D):
	return global_position.distance_to(node.global_position) <= (_collider.shape as CircleShape2D).radius


func _closest_enemy(a: EnemyAlt, b: EnemyAlt) -> EnemyAlt:
	var a_dist = global_position.distance_squared_to(a.global_position)
	var b_dist = global_position.distance_squared_to(b.global_position)
	
	if a_dist < b_dist:
		print("a is closer")
		return a
	print("b is closer")
	
	return b

func _aim(delta: float) -> void:
	if not _target:
		return

	var target_rotation = self.global_position.angle_to_point(_target.global_position)
	self.rotation = rotate_toward(self.rotation, target_rotation, delta * 1.8)


func _fire() -> void:
	if not _target:
		return


func _can_fire() -> bool:
	return Time.get_ticks_msec() - _last_fire_time >= fire_rate


func _on_target_died() -> void:
	_target = null
	_acquire_target()
