class_name Waves
extends Node2D

var break_time: float = 6.0

var _current_wave: int = 0
var _cleared_waves: int = 0
var _state: String = "idle"
var _enemy_spawn: EnemySpawn
var _break_timer: CustomTimer
var _calculator: WaveCalculator


func _init(enemy_spawn: EnemySpawn, cleared_waves: int = 0) -> void:
	_enemy_spawn = enemy_spawn
	_calculator = WaveCalculator.new(enemy_spawn.ENEMIES)
	_break_timer = CustomTimer.new(break_time)
	add_child(_break_timer)

	_cleared_waves = max(0, cleared_waves)
	_current_wave = _cleared_waves + 1


func start() -> void:
	_start_wave()


func get_wave() -> int:
	return _current_wave


func get_cleared_waves() -> int:
	return _cleared_waves


func _start_break() -> void:
	_set_state("break")
	_cleared_waves = _current_wave
	_break_timer.time_changed.connect(SignalBus.break_timer_change.emit)
	_break_timer.start()
	SignalBus.break_started.emit(break_time)
	await _break_timer.timeout
	_start_wave()


func _start_wave() -> void:
	_set_state("spawning")
	_current_wave = _cleared_waves + 1
	var wave = _calculator.get_enemy_spawns(_current_wave)
	_enemy_spawn.spawn_wave(wave)
	SignalBus.wave_started.emit(_current_wave)
	_enemy_spawn.wave_cleared.connect(_start_break)


func _set_state(state: String) -> void:
	assert(state in ["idle", "spawning", "break"], "Invalid wave state: " + state)
	_state = state
