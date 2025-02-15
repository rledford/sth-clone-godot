extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var damage: float = 1.0
var fire_rate: float = 0.25
var fire_timer: float = 0.0
var pierce_limit: int = 0

var max_health: int = 100
var health: int = max_health

func _ready() -> void:
	SignalBus.player_hit.connect(_handle_player_hit)
	SignalBus.player_health_changed.emit(health, max_health)

func y_sort(a, b) -> bool:
	return a.global_position.y > b.global_position.y

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	if fire_timer > 0:
		fire_timer -= delta
	
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot") and can_fire():
		audio_stream_player.play()
		var enemies = area_2d.get_overlapping_bodies()
		enemies.sort_custom(y_sort)
		for i in range(len(enemies)):
			if enemies[i] is Enemy:
				enemies[i].hit.emit(damage)
			if i >= pierce_limit:
				break
			
		fire_timer = fire_rate
		
func can_fire() -> bool:
	return fire_timer <= 0

func _handle_player_hit(amount: float) -> void:
	print("hit player for ", amount)
	health -= amount
	SignalBus.player_health_changed.emit(health, max_health)
