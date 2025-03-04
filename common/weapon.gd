class_name Weapon
extends Node2D


func start_shooting(_point: Vector2) -> void:
	pass


func spray(_point: Vector2) -> void:
	pass


func stop_shooting() -> void:
	pass


func reload() -> void:
	pass


func can_reload() -> bool:
	return true


func get_magazine() -> Magazine:
	return null


func y_sort(a, b) -> bool:
	return a.global_position.y > b.global_position.y
