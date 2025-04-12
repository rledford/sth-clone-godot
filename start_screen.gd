class_name StartScreen
extends CanvasLayer

signal new_game_pressed
signal continue_game_pressed
signal wipe_save_pressed
signal start_debug_game_pressed

const Scene = preload("res://start_screen.tscn")

var _has_saved_game: bool = false

@onready var new_game_btn: Button = %NewGameBtn
@onready var continue_game_btn: Button = %ContinueGameBtn
@onready var wipe_save_btn: Button = %WipeSaveBtn
@onready var start_debug_game_btn: Button = %StartDebugGameBtn


static func create(has_saved_game: bool = false) -> StartScreen:
	var instance = Scene.instantiate()
	instance._has_saved_game = has_saved_game
	return instance


func _ready() -> void:
	new_game_btn.pressed.connect(_on_new_game)
	continue_game_btn.pressed.connect(_on_continue_game)
	wipe_save_btn.pressed.connect(_on_wipe_save)
	start_debug_game_btn.pressed.connect(_on_start_debug_game)
	continue_game_btn.visible = _has_saved_game


func _on_new_game() -> void:
	new_game_pressed.emit()
	queue_free()


func _on_continue_game() -> void:
	continue_game_pressed.emit()
	queue_free()


func _on_wipe_save() -> void:
	wipe_save_pressed.emit()


func _on_start_debug_game() -> void:
	start_debug_game_pressed.emit()
	queue_free()
