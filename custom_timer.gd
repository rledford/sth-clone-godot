class_name CustomTimer
extends Node
## Custom timer that mimics the built-in Timer class
## but with a time_changed signal for updating things like the HUD

signal timeout
signal time_changed(time_left: float)

var time: int
var _start_time_ms: int = 0

var _is_running: bool = false


func _init(duration_seconds: float) -> void:
	set_time(duration_seconds)


func _process(_delta: float) -> void:
	if !_is_running:
		return

	var elapsed_time = Time.get_ticks_msec() - _start_time_ms
	var time_left = time - elapsed_time
	if time_left <= 0:
		timeout.emit()
		_is_running = false
		return
	time_changed.emit(_ms_to_seconds(time_left))


func start() -> void:
	_is_running = true
	_start_time_ms = Time.get_ticks_msec()


func set_time(duration_seconds: float) -> void:
	time = _seconds_to_ms(duration_seconds)


func _seconds_to_ms(seconds: float) -> int:
	return int(seconds * 1000)


func _ms_to_seconds(ms: int) -> float:
	return ms / 1000.0
