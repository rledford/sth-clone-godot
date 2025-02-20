extends Node2D
class_name EnemySpawn

const FlyingEye = preload("res://enemy/flying_eye/flying_eye.tscn")
const Goblin = preload("res://enemy/goblin/goblin.tscn")
const Skeleton = preload("res://enemy/skeleton/skeleton.tscn")
const Mushroom = preload("res://enemy/mushroom/mushroom.tscn")

# Dictionary that maps diffuclty score to a set of enemies
const enemies: Dictionary = {
	1: [FlyingEye],
	2: [Goblin],
	4: [Skeleton],
	6: [Mushroom]
}

signal spawned_all_enemies

var _wave: Array = []
var _spawn_timer: float = 0.0

func spawn_wave(wave: Array) -> void:
	_wave = wave

func is_valid_score(score: int) -> bool:
	return enemies.has(score)

func _physics_process(delta: float) -> void:
	if _wave.is_empty():
		return

	_spawn_timer = max(_spawn_timer - delta, 0)
	
	if _spawn_timer > 0:
		return

	var current = _wave.pop_front()
	var score = current["score"]
	var enemy = enemies.get(score).pick_random().instantiate()
	enemy.global_position = _random_spawn_position()
	
	add_child(enemy)
	_spawn_timer = current["spawn_timer"]

	if _wave.is_empty():
		print("Spawned all enemies!")
		spawned_all_enemies.emit()

func _random_spawn_position() -> Vector2:
	var areas = get_tree().get_nodes_in_group("enemy_spawn_areas") as Array[CollisionShape2D]
	var area: CollisionShape2D = areas.pick_random()
	var size: Vector2 = area.shape.get_rect().size
	
	var rand_x = area.global_position.x
	var rand_y = randf_range(
		area.global_position.y - (size.y * 0.5),
		area.global_position.y + (size.y * 0.5)
	)
	
	return Vector2(rand_x - global_position.x, rand_y - global_position.y)
