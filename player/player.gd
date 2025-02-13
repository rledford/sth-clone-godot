extends Node2D

@onready var area_2d: Area2D = $Area2D

var damage: float = 1.0
var fire_rate: float = 0.25
var fire_timer: float = 0.0
var pierce_limit: int = 0

func _ready() -> void:
	SignalBus.player_hit.connect(_handle_player_hit)

func y_sort(a, b) -> bool:
	return a.global_position.y > b.global_position.y

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	if fire_timer > 0:
		fire_timer -= delta
	
func _physics_process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_fire():
		var enemies = area_2d.get_overlapping_bodies()
		enemies.sort_custom(y_sort)
		for i in range(len(enemies)):
			if enemies[i] is Enemy:
				enemies[i].hit.emit(1.0)
			if i >= pierce_limit:
				break
			
		fire_timer = fire_rate
		
func can_fire() -> bool:
	return fire_timer <= 0

func _handle_player_hit(damage: float) -> void:
	print("hit player for ", damage)
	
