class_name WaveCalculator
extends Resource

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var _enemies: Dictionary  # Was not able to type the dict either


func _init(enemies: Dictionary) -> void:
	_enemies = enemies


# Array[Dictionary] doesn't work :sad: https://forum.godotengine.org/t/array-with-dictionaries-doesnt-get-recognized-as-array-dictionary/58280
func get_enemy_spawns(wave_number: int) -> Array:
	var difficulty = _get_difficulty(wave_number)
	var max_batch_score = _get_max_batch_score(difficulty)
	var total_batches = max(1, ceil(float(difficulty) / max_batch_score))

	var result = []
	var total_difficulty = 0

	for _index in range(total_batches):
		var enemy_difficulty_pool = _enemies.keys().filter(
			_lessThanEqualTo(_get_max_enemy_score(difficulty))
		)
		var max_enemy_difficulty = enemy_difficulty_pool.max()

		var batch = []
		var batch_score = 0
		var target_batch_score = min(difficulty - total_difficulty, max_batch_score)

		while batch_score < target_batch_score and total_difficulty < difficulty:
			var remaining_batch_score = target_batch_score - batch_score
			if remaining_batch_score < max_enemy_difficulty:
				enemy_difficulty_pool = enemy_difficulty_pool.filter(
					_lessThanEqualTo(remaining_batch_score)
				)
				max_enemy_difficulty = enemy_difficulty_pool.max()

			var enemy_difficulty = enemy_difficulty_pool.pick_random()

			batch_score += enemy_difficulty
			total_difficulty += enemy_difficulty

			batch.append(enemy_difficulty)

		result.append(batch)

	return result


func get_wave_frequency(wave_number: int) -> float:
	# Just an arbitrary formula for adjusting frequency so by wave 30, batches spawn at ~0.5 second intervals
	return 1/((_get_difficulty(wave_number) + 1)/30.0)


func _get_difficulty(wave_number: int) -> int:
	# Diffuclty increases linearly, which is boring, should have some more interesting curve
	return 5 + ceil(wave_number * 1.5)


func _get_max_enemy_score(difficulty: int) -> int:
	@warning_ignore("integer_division")
	return max(ceil(difficulty / 6), 1)


func _get_max_batch_score(difficulty: int) -> int:
	return 10 + ceil(difficulty * 0.33)


func _sum(array: Array[int]) -> int:
	if array.is_empty():
		return 0
	return array.reduce(func(x, y): return x + y)


func _lessThanEqualTo(limit: int) -> Callable:
	return func(value): return value <= limit
