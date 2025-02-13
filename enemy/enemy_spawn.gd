extends Node2D

const FlyingEye = preload("res://enemy/flying_eye/flying_eye.tscn")

var spawn_time = 2.0
var spawn_timer = 0.0

func random_spawn_position() -> Vector2:
	var areas = get_tree().get_nodes_in_group("enemy_spawn_areas") as Array[CollisionShape2D]
	var area: CollisionShape2D = areas.pick_random()
	var size: Vector2 = area.shape.get_rect().size
	
	var rand_x = area.global_position.x
	var rand_y = randf_range(
		area.global_position.y - (size.y * 0.5),
		area.global_position.y + (size.y * 0.5)
	)
	
	return Vector2(rand_x - global_position.x, rand_y - global_position.y)

func _physics_process(delta: float) -> void:
	spawn_timer -= delta
	
	if spawn_timer > 0:
		return
		
	var enemy = FlyingEye.instantiate()
	enemy.global_position = random_spawn_position()
	
	add_child(enemy)
	
	spawn_timer = spawn_time
