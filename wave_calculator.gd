class_name WaveCalculator
extends Resource

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var _base_spawn_time: float
var _enemies: Dictionary  # Was not able to type the dict either

const MAX_WAVE_BATCH_SCORE = 10


func _init(base_spawn_time: float, enemies: Dictionary) -> void:
	_base_spawn_time = base_spawn_time
	_enemies = enemies


# Array[Dictionary] doesn't work :sad: https://forum.godotengine.org/t/array-with-dictionaries-doesnt-get-recognized-as-array-dictionary/58280
func get_enemy_spawns(wave_number: int):
	var difficulty = _get_difficulty(wave_number)
	var total_batches = max(1, ceil(float(difficulty) / MAX_WAVE_BATCH_SCORE))

	var result = []
	var total_difficulty = 0

	for _index in range(total_batches):
		var enemy_difficulty_pool = _enemies.keys().filter(
			_filter_lte(_get_max_enemy_score(difficulty))
		)
		var max_enemy_difficulty = enemy_difficulty_pool.max()

		var batch = []
		var batch_score = 0
		var target_batch_score = min(difficulty - total_difficulty, MAX_WAVE_BATCH_SCORE)

		while batch_score < target_batch_score and total_difficulty < difficulty:
			var remaining_batch_score = target_batch_score - batch_score
			if remaining_batch_score < max_enemy_difficulty:
				enemy_difficulty_pool = enemy_difficulty_pool.filter(
					_filter_lte(remaining_batch_score)
				)
				max_enemy_difficulty = enemy_difficulty_pool.max()

			var enemy_difficulty = enemy_difficulty_pool.pick_random()

			batch_score += enemy_difficulty
			total_difficulty += enemy_difficulty

			batch.append(enemy_difficulty)

		result.append(batch)

	return result


func _add_spawn_timer(score: int) -> Dictionary:
	var spawn_timer = _get_spawn_timer(score)

	return {"score": score, "spawn_timer": spawn_timer}


func _get_enemy_scores(difficulty: int) -> Array[int]:
	var max_enemy_score: int = _get_max_enemy_score(difficulty)

	var scores: Array[int] = []

	while _sum(scores) < difficulty:
		var difficulty_left = difficulty - _sum(scores)
		var max_range = min(max_enemy_score, difficulty_left)
		var score = rng.randi_range(1, max_range)

		# NOTE: this should be changed, instead of re-rolling, we can split the score into two enemies that are indeed valid
		while not _is_valid_score(score):
			score = rng.randi_range(1, max_range)
		scores.append(score)

	return scores


## Gives a semi-random spawn timer based on the wave number
func _get_spawn_timer(wave_number: int) -> float:
	var difficulty = _get_difficulty(wave_number)
	# Kind of boring adjustment, but it will do for now
	var adjusted_timer = clampf(_base_spawn_time - (difficulty * 0.02), 0.2, _base_spawn_time)

	var random_number = rng.randf_range(0.4, 1)
	return adjusted_timer * random_number


func _is_valid_score(score: int) -> bool:
	return _enemies.has(score)


func _get_difficulty(wave_number: int) -> int:
	# Diffuclty increases linearly, which is boring, should have some more interesting curve
	return 5 + log(wave_number + 1) + wave_number


func _get_max_enemy_score(difficulty: int) -> int:
	@warning_ignore("integer_division")
	return max(ceil(difficulty / 6), 1)


func _sum(array: Array[int]) -> int:
	if array.is_empty():
		return 0
	return array.reduce(func(x, y): return x + y)


func _filter_lte(limit: int) -> Callable:
	return func(value): return value <= limit
