class_name HUD
extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var ammo_bar: ProgressBar = $AmmoBar
@onready var ammo_bar_label: Label = $AmmoBar/AmmoBarLabel

const scene = preload("res://hud/hud.tscn")

var _init_health: int
var _init_max_health: int

var _init_ammo: int
var _init_max_ammo: int

static func create(health: int, max_health: int, ammo: int, max_ammo: int) -> HUD:
	var instance = scene.instantiate()
	
	instance._init_health = health
	instance._init_max_health = max_health
	
	instance._init_ammo = ammo
	instance._init_max_ammo = max_ammo
	
	return instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.value = _init_health
	health_bar.max_value = _init_max_health
	
	ammo_bar.value = _init_ammo
	ammo_bar.max_value = _init_max_ammo
	
	update_ammo_bar_text()
	
	SignalBus.player_health_changed.connect(_handle_player_health_changed)
	SignalBus.player_ammo_changed.connect(_handle_player_ammo_changed)

func _handle_player_health_changed(health: int, max_health: int) -> void:
	health_bar.value = health
	health_bar.max_value = max_health
	
func _handle_player_ammo_changed(ammo: int, max_ammo: int) -> void:
	ammo_bar.value = ammo
	ammo_bar.max_value = max_ammo
	
	update_ammo_bar_text()
	
func update_ammo_bar_text() -> void:
	ammo_bar_label.text = str(ammo_bar.value) + " / " + str(ammo_bar.max_value)
