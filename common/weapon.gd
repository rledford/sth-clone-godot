class_name Weapon
extends Node2D


func pull_trigger() -> void:
	pass


func release_trigger() -> void:
	pass


func point_to(_point: Vector2) -> void:
	pass


func reload() -> void:
	pass


func can_reload() -> bool:
	return true


func get_magazine() -> Magazine:
	return null


func y_sort(a, b) -> bool:
	return a.global_position.y > b.global_position.y
