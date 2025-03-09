class_name EnemySpawn
extends Node2D

signal wave_cleared

const Zombie = preload("res://enemy/undead/zombie/zombie.tscn")
const ZombieLumberjack = preload("res://enemy/undead/zombie_lumberjack/zombie_lumberjack.tscn")
const Lich = preload("res://enemy/undead/lich/lich.tscn")

# Dictionary that maps diffuclty score to a set of enemies
const ENEMIES: Dictionary = {1: [Zombie], 4: [ZombieLumberjack], 6: [Lich]}


func spawn_wave(wave: Array) -> void:
	var total_enemies = 0
	for batch in wave:
		print("[Enemy Spawn] Spawning enemies in batch\n", batch)
		for enemy_difficulty in batch:
			total_enemies += 1
			var enemy = _spawn(enemy_difficulty)
			enemy.died.connect(_on_enemy_died)

		await get_tree().create_timer(2.0).timeout
	
	print("[Enemy Spawn] Total enemies spawned: ", total_enemies)


func _on_enemy_died() -> void:
	if len(get_tree().get_nodes_in_group("enemies")) == 0:
		wave_cleared.emit()


func _spawn(score: int) -> EnemyAlt:
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
		area.global_position.x - (size.x * 0.5), area.global_position.x + (size.x * 0.5)
	)

	var rand_y = randf_range(
		area.global_position.y - (size.y * 0.5), area.global_position.y + (size.y * 0.5)
	)

	return Vector2(rand_x - global_position.x, rand_y - global_position.y)
