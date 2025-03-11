extends EnemyAlt

var Projectile: PackedScene = preload("res://enemy/undead/lich/lich_projectile.tscn")

@onready var projectile_spawn: Node2D = $ProjectileSpawn

func _on_entered_attack_hit_frame() -> void:
	var dir = global_position.direction_to(projectile_spawn.global_position)
	var proj = Projectile.instantiate() as Projectile
	proj.global_position = Vector2(projectile_spawn.global_position)
	proj.direction = dir
	get_tree().root.add_child(proj)
