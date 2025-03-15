class_name HUD
extends CanvasLayer

const Scene = preload("res://hud/hud.tscn")

var _init_health: int
var _init_max_health: int

var _init_ammo: int
var _init_max_ammo: int

var _init_coins: int

@onready var break_label: Label = %BreakLabel
@onready var wave_counter_label: Label = %WaveCounterLabel
@onready var bottom_ui: BottomUI = $BottomUI


static func create(health: int, max_health: int, ammo: int, max_ammo: int, coins: int) -> HUD:
	var instance = Scene.instantiate()

	instance._init_health = health
	instance._init_max_health = max_health

	instance._init_ammo = ammo
	instance._init_max_ammo = max_ammo

	instance._init_coins = coins

	return instance


func _ready() -> void:
	bottom_ui.render(_init_health, _init_max_health, _init_ammo, _init_max_ammo, _init_coins)
	SignalBus.break_started.connect(_handle_break_started)
	SignalBus.break_timer_change.connect(_update_break_timer)
	SignalBus.wave_started.connect(_handle_wave_started)


func _update_break_timer(break_time: float) -> void:
	break_label.text = "NEXT WAVE IN %3.1f" % break_time


func _handle_break_started(break_time: float) -> void:
	break_label.show()
	_update_break_timer(break_time)


func _handle_wave_started(wave: int) -> void:
	break_label.hide()
	wave_counter_label.text = "WAVE %3d" % wave
