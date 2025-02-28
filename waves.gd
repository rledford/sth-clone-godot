class_name Waves
extends Node2D

var base_spawn_time: float = 2.5
var break_time: float = 10.0

var _wave: int = 0
var _state: String = "idle"
var _enemy_spawn: EnemySpawn

var _break_timer: CustomTimer

var _calculator: WaveCalculator


func _init(enemy_spawn: EnemySpawn) -> void:
	_enemy_spawn = enemy_spawn
	_calculator = WaveCalculator.new(base_spawn_time, enemy_spawn.ENEMIES)
	_break_timer = CustomTimer.new(break_time)
	add_child(_break_timer)


func start() -> void:
	_start_wave()


func get_wave() -> int:
	return _wave


func _start_break() -> void:
	_set_state("break")
	_break_timer.time_changed.connect(SignalBus.break_timer_change.emit)
	_break_timer.start()
	SignalBus.break_started.emit(break_time)
	await _break_timer.timeout
	_start_wave()


func _start_wave() -> void:
	_set_state("spawning")
	_wave += 1
	var wave = _calculator.get_enemy_spawns(_wave)
	print("[Waves] Starting " + str(_wave) + " with " + str(wave))
	_enemy_spawn.spawn_wave(wave)
	SignalBus.wave_started.emit(_wave)
	_enemy_spawn.wave_cleared.connect(_start_break)


func _set_state(state: String) -> void:
	assert(state in ["idle", "spawning", "break"], "Invalid wave state: " + state)
	_state = state
