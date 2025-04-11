extends Node2D

var _game: Game
var _end_screen: EndScreen
var _start_screen: StartScreen
var _music: Music


func _ready() -> void:
	_music = Music.new()
	add_child(_music)
	SignalBus.game_over.connect(_handle_game_over)
	SignalBus.start_new_game.connect(_handle_new_game)

	# Show start screen instead of immediately starting a new game
	_show_start_screen()


func _show_start_screen() -> void:
	_start_screen = StartScreen.create()
	_start_screen.start_game_pressed.connect(_handle_start_game)
	add_child(_start_screen)


func _handle_start_game() -> void:
	_delete_start_screen()
	_new_game()


func _new_game() -> void:
	_game = Game.create()
	add_child(_game)


func _handle_game_over(wave: int) -> void:
	_end_screen = EndScreen.create(wave)
	_delete_game()
	add_child(_end_screen)


func _handle_new_game() -> void:
	_delete_end_screen()
	_new_game()


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
