extends Node
class_name State

var _enter: Callable
var _exit: Callable
var _update: Callable


func on_enter(cb: Callable) -> State:
	_enter = cb
	return self


func on_update(cb: Callable) -> State:
	_update = cb
	return self


func on_exit(cb: Callable) -> State:
	_exit = cb
	return self


func enter() -> void:
	if _enter:
		_enter.call()


func update(delta: float):
	if _update:
		_update.call(delta)


func exit() -> void:
	if _exit:
		_exit.call()
