extends Node
class_name StateMachine

var _current_state: State
var _current_state_id: String
var _states = {}


func get_current_state_id() -> String:
	return _current_state_id


func add_state(id: String, state: State):
	_states[id] = state


func change_state(id: String):
	var next_state = _states[id]

	if not next_state:
		print("unknown state ", id)
		return

	if _current_state:
		_current_state.exit()

	next_state.enter()
	_current_state = next_state
	_current_state_id = id


func _physics_process(delta: float) -> void:
	if not _current_state:
		return

	_current_state.update(delta)
