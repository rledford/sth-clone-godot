class_name EndScreen
extends Node2D

@onready var score_label: Label = %ScoreLabel
@onready var new_game_btn: Button = %NewGameBtn

const scene = preload("res://end_screen.tscn")
var _wave: int


static func create(wave: int) -> EndScreen:
	var instance = scene.instantiate()
	instance._wave = wave
	return instance


func _ready() -> void:
	score_label.text = "REACHED WAVE " + String.num(_wave)
	new_game_btn.pressed.connect(_on_new_game)


func _on_new_game() -> void:
	SignalBus.start_new_game.emit()
