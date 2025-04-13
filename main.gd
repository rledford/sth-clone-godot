extends Node2D

var _game: Game
var _end_screen: EndScreen
var _start_screen: StartScreen
var _music: Music
var _saved_game: SavedGame


func _ready() -> void:
	_saved_game = SavedGame.new()
	_music = Music.new()
	add_child(_music)
	SignalBus.game_over.connect(_on_game_over)
	SignalBus.start_new_game.connect(_on_start_new_game)

	_show_start_screen()


func _show_start_screen() -> void:
	var has_saved_game = _check_for_saved_game()
	_start_screen = StartScreen.create(has_saved_game)
	_start_screen.new_game_pressed.connect(_on_start_screen_new_game_pressed)
	_start_screen.continue_game_pressed.connect(_on_start_screen_continue_game_pressed)
	_start_screen.wipe_save_pressed.connect(_on_start_screen_wipe_save_pressed)
	_start_screen.start_debug_game_pressed.connect(_on_start_screen_start_debug_game_pressed)
	add_child(_start_screen)


func _check_for_saved_game() -> bool:
	var save_data = _saved_game.get_save_data()
	return save_data.current_game.has("is_running") and save_data.current_game.is_running


func _on_start_screen_new_game_pressed() -> void:
	_delete_start_screen()
	_saved_game.reset_current_game()
	var game_state = {
		"is_running": true,
		"coins": 0,
		"cleared_waves": 0,
	}
	_start_game(game_state)


func _on_start_screen_continue_game_pressed() -> void:
	_delete_start_screen()
	var save_data = _saved_game.get_save_data()
	_start_game(save_data.current_game)


func _on_start_screen_wipe_save_pressed() -> void:
	_saved_game.wipe_save_data()
	_delete_start_screen()
	_show_start_screen()


func _on_start_screen_start_debug_game_pressed() -> void:
	_delete_start_screen()
	_saved_game.reset_current_game()
	_new_debug_game()


func _start_game(game_state: Dictionary) -> void:
	_game = Game.create(game_state)
	add_child(_game)
	print("[Main] Starting game with state: ", game_state)


func _new_debug_game() -> void:
	var game_state = {
		"is_running": true,
		"coins": 1000000,
		"cleared_waves": 0,
	}
	print("[Main] Starting debug game with 1,000,000 coins")
	_start_game(game_state)


func _on_game_over(cleared_waves: int) -> void:
	var game_state = {
		"is_running": false,
		"coins": 0,
		"cleared_waves": cleared_waves,
	}
	SignalBus.game_state_changed.emit(game_state)

	_end_screen = EndScreen.create(cleared_waves)
	_delete_game()
	add_child(_end_screen)


func _on_start_new_game() -> void:
	_delete_end_screen()
	_on_start_screen_new_game_pressed()


func _delete_game() -> void:
	if _game:
		_game.queue_free()
		_game = null


func _delete_end_screen() -> void:
	if _end_screen:
		_end_screen.queue_free()
		_end_screen = null


func _delete_start_screen() -> void:
	if _start_screen:
		_start_screen.queue_free()
		_start_screen = null
