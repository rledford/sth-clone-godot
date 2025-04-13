class_name StartScreen
extends CanvasLayer

signal new_game_pressed
signal continue_game_pressed
signal wipe_save_pressed
signal start_debug_game_pressed

const Scene = preload("res://start_screen.tscn")

var _has_saved_game: bool = false
var _confirm_dialog: ConfirmationDialog

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
	wipe_save_btn.pressed.connect(_on_wipe_save_button_pressed)
	start_debug_game_btn.pressed.connect(_on_start_debug_game)
	continue_game_btn.visible = _has_saved_game

	_setup_confirm_dialog()


func _setup_confirm_dialog() -> void:
	_confirm_dialog = ConfirmationDialog.new()
	_confirm_dialog.title = "Confirm Wipe Save Data"
	_confirm_dialog.dialog_text = """Are you sure you want to wipe all save data?
	This action cannot be undone."""
	_confirm_dialog.confirmed.connect(_on_wipe_save_confirmed)
	_confirm_dialog.get_cancel_button().text = "Cancel"
	_confirm_dialog.get_ok_button().text = "Wipe Data"
	_confirm_dialog.min_size = Vector2(300, 100)
	add_child(_confirm_dialog)


func _on_new_game() -> void:
	new_game_pressed.emit()
	queue_free()


func _on_continue_game() -> void:
	continue_game_pressed.emit()
	queue_free()


func _on_wipe_save_button_pressed() -> void:
	_confirm_dialog.popup_centered()


func _on_wipe_save_confirmed() -> void:
	wipe_save_pressed.emit()


func _on_start_debug_game() -> void:
	start_debug_game_pressed.emit()
	queue_free()
