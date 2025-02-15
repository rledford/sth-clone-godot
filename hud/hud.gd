class_name HUD
extends CanvasLayer
@onready var health_bar: ProgressBar = $ProgressBar

const scene = preload("res://hud/hud.tscn")

var _init_health: int
var _init_max_health: int

static func create(health: int, max_health: int) -> HUD:
	var instance = scene.instantiate()
	instance._init_health = health
	instance._init_max_health = max_health
	return instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.value = _init_health
	health_bar.max_value = _init_max_health
	SignalBus.player_health_changed.connect(_handle_player_health_changed)

func _handle_player_health_changed(health: int, max_health: int) -> void:
	health_bar.value = health
	health_bar.max_value = max_health
