class_name Waves
extends Node2D

var base_spawn_time: float = 3.0
var break_time: float = 10.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var _wave: int = 0
var _break_timer: float = 0.0
var _state: String = "idle"
var _enemy_spawn: EnemySpawn

var _spawned_all_enemies: bool = false

func _init(enemy_spawn: EnemySpawn) -> void:
	_enemy_spawn  = enemy_spawn

func start() -> void:
	_enemy_spawn.spawned_all_enemies.connect(func(): _spawned_all_enemies = true)
	_start_wave()

func _process(delta: float) -> void:
	if _state == "break":
		_break_timer = max(_break_timer - delta, 0)
		if _break_timer <= 0:
			_start_wave()
	elif _state == "spawning":
		var are_all_enemies_dead = get_tree().get_nodes_in_group("enemies").is_empty()
		if(are_all_enemies_dead and _spawned_all_enemies):
			_start_break()

func _start_break() -> void:
	_set_state("break")
	_break_timer = break_time
	SignalBus.break_started.emit(break_time)

func _start_wave() -> void:
	_set_state("spawning")
	_wave += 1
	var wave = get_enemy_spawns(_wave)
	_spawned_all_enemies = false
	print("Starting wave " + str(_wave) + " with " + str(wave))
	_enemy_spawn.spawn_wave(wave)
	SignalBus.wave_started.emit(_wave)

func _set_state(state: String) -> void:
	assert (state in ["idle", "spawning", "break"], "Invalid wave state: " + state)
	_state = state

# These wave calculators should be on a different file

# Array[Dictionary] doesn't work :sad: https://forum.godotengine.org/t/array-with-dictionaries-doesnt-get-recognized-as-array-dictionary/58280
func get_enemy_spawns(wave_number: int) -> Array:
	var difficulty = get_difficulty(wave_number)

	var enemy_scores = get_enemy_scores(difficulty)

	print("Enemy scores for difficulty " + str(difficulty) + ": " + str(enemy_scores))

	return enemy_scores.map(add_spawn_timer)

func add_spawn_timer(score: int) -> Dictionary:
	var spawn_timer = get_spawn_timer(score)

	return {
		"score": score,
		"spawn_timer": spawn_timer
	}


func get_enemy_scores(difficulty: int) -> Array[int]:
	var max_enemy_score : int = get_max_enemy_score(difficulty) 

	var scores: Array[int] = []

	while sum(scores) < difficulty:
		var difficulty_left = difficulty - sum(scores)
		var max_range = min(max_enemy_score, difficulty_left)
		var score = rng.randi_range(1, max_range)
		
		# NOTE: this should be changed, instead of re-rolling, we can split the score into two enemies that are indeed valid
		while not _enemy_spawn.is_valid_score(score):
			score = rng.randi_range(1, max_range)
		scores.append(score)

	return scores
	
func get_difficulty(wave_number: int) -> int:
	# Diffuclty increases linearly, which is boring, should have some more interesting curve
	return wave_number * 3

## Gives a semi-random spawn timer based on the wave number
func get_spawn_timer(wave_number: int) -> float:
	var difficulty = get_difficulty(wave_number) 
	# Kind of boring adjustment, but it will do for now
	var adjusted_timer = clampf(base_spawn_time - (difficulty * 0.01), 0.2, base_spawn_time)

	var random_number = rng.randf_range(0.6, 1)
	return adjusted_timer * random_number

func get_max_enemy_score(difficulty: int) -> int:
	@warning_ignore("integer_division")
	return max(ceil( difficulty / 4), 1)

func sum(array: Array[int]) -> int:
	if array.is_empty(): return 0
	return array.reduce(func(x, y): return x + y)
