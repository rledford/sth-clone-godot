class_name EnemySpawn
extends Node2D

signal wave_cleared

const FlyingEye = preload("res://enemy/flying_eye/flying_eye.tscn")
const Goblin = preload("res://enemy/goblin/goblin.tscn")
const Skeleton = preload("res://enemy/skeleton/skeleton.tscn")
const Mushroom = preload("res://enemy/mushroom/mushroom.tscn")

# Dictionary that maps diffuclty score to a set of enemies
const ENEMIES: Dictionary = {1: [FlyingEye], 2: [Goblin], 4: [Skeleton], 6: [Mushroom]}


func spawn_wave(wave) -> void:
	for batch in wave:
		print("[Enemy Spawn] Spawning batch ", batch)
		for enemy_difficulty in batch:
			var enemy = _spawn(enemy_difficulty)
			enemy.died.connect(_on_enemy_died)

		await get_tree().create_timer(1.0).timeout

func _on_enemy_died() -> void:
		if len(get_tree().get_nodes_in_group("enemies")) == 0:
			wave_cleared.emit()


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

	var rand_x = randf_range(
		area.global_position.x - (size.x *0.5), area.global_position.x + (size.x * 0.5)
	)

	var rand_y = randf_range(
		area.global_position.y - (size.y * 0.5), area.global_position.y + (size.y * 0.5)
	)

	return Vector2(rand_x - global_position.x, rand_y - global_position.y)
