extends Node2D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var health = 100
	var max_health = 100
	var player = Player.create(health, max_health)
	add_child(player)

	var hud = HUD.create(health, max_health)
	add_child(hud)
	
