extends Node2D

const hit_particle = preload("res://particles/ground_hit_particle.tscn")

func _ready() -> void:
	SignalBus.shot_hit_ground.connect(_handle_hit)
	
func _handle_hit(global_position: Vector2) -> void:
	var particle = hit_particle.instantiate()
	particle.position = global_position
	particle.one_shot = true
	particle.color = Color.BURLYWOOD

	add_child(particle)
