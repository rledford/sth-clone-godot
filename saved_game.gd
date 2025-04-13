class_name SavedGame
extends Resource

const SAVE_FILE_PATH = "user://saved_game.json"
const DEFAULT_SAVE_DATA = {
	"current_game":
	{
		"is_running": false,
		"coins": 0,
		"cleared_waves": 0,
		"upgrades": {},
		"occupants": [],
		"turrets": []
	}
}

var _current_save_data: Dictionary = DEFAULT_SAVE_DATA.duplicate(true)


func _init() -> void:
	SignalBus.game_state_changed.connect(_on_game_state_changed)
	_load_game()
	print("[SavedGame] Loaded save data: ", _current_save_data)


func get_save_data() -> Dictionary:
	return _current_save_data.duplicate(true)


func get_current_game() -> Dictionary:
	return _current_save_data.current_game.duplicate()


func wipe_save_data() -> void:
	_current_save_data = DEFAULT_SAVE_DATA.duplicate(true)
	_save_game()
	print("[SavedGame] Save data wiped")


func reset_current_game() -> void:
	_current_save_data.current_game = DEFAULT_SAVE_DATA.current_game.duplicate()
	_save_game()
	print("[SavedGame] Current game reset")


func _on_game_state_changed(data: Dictionary) -> void:
	_current_save_data.current_game = {
		"is_running": data.get("is_running", false),
		"coins": data.get("coins", 0),
		"cleared_waves": data.get("cleared_waves", 0),
		"upgrades": data.get("upgrades", {}),
		"occupants": data.get("occupants", []),
		"turrets": data.get("turrets", [])
	}
	_save_game()
	print("[SavedGame] Game state updated: ", _current_save_data.current_game)


func _save_game() -> void:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_current_save_data))
		print("[SavedGame] Game saved successfully")
	else:
		push_error("[SavedGame] Failed to save game")


func _load_game() -> void:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			var json = JSON.new()
			var parse_result = json.parse(json_string)

			if parse_result == OK:
				var data = json.get_data()
				if _is_valid_save_data(data):
					_current_save_data = data
				else:
					push_error("[SavedGame] Invalid save data format")
			else:
				push_error("[SavedGame] JSON Parse Error: " + json.get_error_message())
	else:
		print("[SavedGame] No save file found, using default values")


func _is_valid_save_data(data: Dictionary) -> bool:
	return (
		data.has("current_game")
		and data.current_game.has("is_running")
		and data.current_game.has("coins")
		and data.current_game.has("cleared_waves")
	)
