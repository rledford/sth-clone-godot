class_name WaveCalculator
extends Resource

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var _enemies: Dictionary  # Was not able to type the dict either


func _init(enemies: Dictionary) -> void:
	_enemies = enemies


# Array[Dictionary] doesn't work :sad: https://forum.godotengine.org/t/array-with-dictionaries-doesnt-get-recognized-as-array-dictionary/58280
func get_enemy_spawns(wave_number: int) -> Array:
	var result = []

	var difficulty = _calculate_wave_difficulty(wave_number)
	var max_enemy_cost = _calculate_max_enemy_cost(difficulty)
	var enemy_choices = _enemies.keys().filter(_less_than_equal_to(max_enemy_cost))
	var max_batch_cost = max_enemy_cost * 5
	var min_enemy_count = ceil(difficulty/1.5)
	var batch_count = ceil(float(difficulty) / max_batch_cost)

	print(
		"[Wave Calc] Wave parameters",
		"\n\tdifficulty: ", difficulty,
		"\n\tmin_enemy_count: ", min_enemy_count,
		"\n\tmax_enemy_cost: ", max_enemy_cost,
		"\n\tmax_batch_cost: ", max_batch_cost,
		"\n\tbatch_count: ", batch_count
	)

	var total_wave_cost = 0
	var total_enemies = 0
	
	for _i in batch_count:
		var batch_cost = min(difficulty - total_wave_cost, max_batch_cost)
		var batch = _batch(batch_cost, enemy_choices)
		
		result.append(batch)
		total_enemies += len(batch)
		total_wave_cost += batch_cost
	
	if min_enemy_count > total_enemies:
		print("[Wave Calc] Adding extra batch")
		var extra_batch = []
		for _i in min_enemy_count - total_enemies:
			extra_batch.append(enemy_choices.pick_random())
		result.append(extra_batch)

	return result


func _calculate_wave_difficulty(wave_number: int) -> int:
	return 20 + ceil(wave_number**1.5)


func _calculate_max_enemy_cost(difficulty: int) -> int:
	return ceil(sqrt(difficulty * 0.33))


func _batch(target_score: int, enemy_score_choices: Array) -> Array:
	var remaining_score = target_score
	var choices = enemy_score_choices.duplicate()
	var max_choice = choices.max()
	var batch = []

	while remaining_score > 0:
		if remaining_score < max_choice:
			choices = choices.filter(_less_than_equal_to(remaining_score))
			max_choice = choices.max()

		batch.append(choices.pick_random())
		remaining_score -= batch[-1]

	return batch


func _sum(array: Array[int]) -> int:
	if array.is_empty():
		return 0
	return array.reduce(func(x, y): return x + y)


func _less_than_equal_to(limit: int) -> Callable:
	return func(value): return value <= limit
