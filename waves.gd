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

var _calculator: WaveCalculator

func _init(enemy_spawn: EnemySpawn) -> void:
	_enemy_spawn  = enemy_spawn
	_calculator = WaveCalculator.new(base_spawn_time, enemy_spawn.enemies)

func start() -> void:
	_enemy_spawn.spawned_all_enemies.connect(func(): _spawned_all_enemies = true)
	_start_wave()

func _process(delta: float) -> void:
	if _state == "break":
		_break_timer = max(_break_timer - delta, 0)
		SignalBus.break_timer_change.emit(_break_timer)
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
	var wave = _calculator.get_enemy_spawns(_wave)
	_spawned_all_enemies = false
	print("Starting wave " + str(_wave) + " with " + str(wave))
	_enemy_spawn.spawn_wave(wave)
	SignalBus.wave_started.emit(_wave)

func _set_state(state: String) -> void:
	assert (state in ["idle", "spawning", "break"], "Invalid wave state: " + state)
	_state = state
