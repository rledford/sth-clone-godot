class_name EnemySpawn
extends Node2D

signal wave_cleared

const FlyingEye = preload("res://enemy/flying_eye/flying_eye.tscn")
const Goblin = preload("res://enemy/goblin/goblin.tscn")
const Skeleton = preload("res://enemy/skeleton/skeleton.tscn")
const Mushroom = preload("res://enemy/mushroom/mushroom.tscn")

# Dictionary that maps diffuclty score to a set of enemies
const ENEMIES: Dictionary = {1: [FlyingEye], 2: [Goblin], 4: [Skeleton], 6: [Mushroom]}


func spawn_wave(wave: Array) -> void:
	var last_spawned_enemy

	for item in wave:
		last_spawned_enemy = _spawn(item.score)
		await get_tree().create_timer(item.spawn_timer).timeout

	last_spawned_enemy.died.connect(wave_cleared.emit)


func is_valid_score(score: int) -> bool:
	return ENEMIES.has(score)


func _spawn(score: int) -> Enemy:
	var enemy = ENEMIES.get(score).pick_random().instantiate()
	enemy.add_to_group("enemies")
	enemy.global_position = _random_spawn_position()
	add_child(enemy)
	return enemy


func _random_spawn_position() -> Vector2:
	var areas = get_tree().get_nodes_in_group("enemy_spawn_areas") as Array[CollisionShape2D]
	var area: CollisionShape2D = areas.pick_random()
	var size: Vector2 = area.shape.get_rect().size

	var rand_x = area.global_position.x
	var rand_y = randf_range(
		area.global_position.y - (size.y * 0.5), area.global_position.y + (size.y * 0.5)
	)

	return Vector2(rand_x - global_position.x, rand_y - global_position.y)
