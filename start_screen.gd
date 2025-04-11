class_name StartScreen
extends CanvasLayer

signal start_game_pressed

const Scene = preload("res://start_screen.tscn")

@onready var start_game_btn: Button = %StartGameBtn


static func create() -> StartScreen:
	var instance = Scene.instantiate()
	return instance


func _ready() -> void:
	start_game_btn.pressed.connect(_on_start_game)


func _on_start_game() -> void:
	start_game_pressed.emit()
	queue_free()
