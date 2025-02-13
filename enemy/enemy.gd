extends CharacterBody2D
class_name Enemy

signal hit(damage: float)

func filter_attack_areas(area) -> bool:
	return area is CollisionShape2D

func _get_attack_position() -> Vector2:
	var areas = get_tree().get_nodes_in_group("attack_areas").filter(filter_attack_areas) as Array[CollisionShape2D]
	var target = areas.pick_random() as CollisionShape2D
	if not target:
		return Vector2.INF
	var target_size = target.shape.get_rect().size as Vector2
	var rand_x = target.global_position.x - (target_size.x * 0.5)
	
	var rand_y = randi_range(
		target.global_position.y - (target_size.y * 0.5),
		target.global_position.y + (target_size.y * 0.5)
	)
	return Vector2(rand_x, rand_y)

func _handle_hit(damage: float) -> void:
	print("_handle_hit not implemented")

func _enter_tree() -> void:
	hit.connect(_handle_hit)
