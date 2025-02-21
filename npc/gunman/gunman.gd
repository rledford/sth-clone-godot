extends Node2D
class_name Gunman

var _target: Enemy
var damage = 1
var _aim_time: float = 1.0
var _aim_timer: float = 0.0
var _fire_time: float = 1.0
var _fire_timer: float = 0.0

func _ready() -> void:
	_aim_timer = _aim_time
	_fire_timer = _fire_time

func _physics_process(delta: float) -> void:
	if not _target:
		print("need target")
		var enemies = get_tree().get_nodes_in_group("enemy")
		if len(enemies):
			# should iterate to find closest
			_target = enemies[0]
	else:
		_fire_timer -= delta
		if _fire_timer <= 0:
			_fire_timer = _fire_time
			print("shoot")
			_target.hit.emit(damage)
			
