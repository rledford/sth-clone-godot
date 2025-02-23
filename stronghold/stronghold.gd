extends Node2D
class_name Stronghold

const Gunman = preload("res://npc/gunman/gunman.tscn")

func _ready() -> void:
	GunmanUpgrade.new().level_change.connect(_handle_gunman_upgrade)

func _handle_gunman_upgrade(level: int):
	var gunman = Gunman.instantiate()
	var posts = get_tree().get_nodes_in_group("gunman_posts") as Array[Node2D]
	var min_occupancy = posts.map(
		func (p): return p.get_child_count()).reduce(
			func (min, value): return value if value < min else min)
	
	posts.filter(
		func (p): return p.get_child_count() <= min_occupancy).pick_random().add_child(gunman)
	
	var target_areas = get_tree().get_nodes_in_group("enemy_spawn_areas") as Array[CollisionShape2D]
	var area: CollisionShape2D = target_areas.pick_random()
	gunman.rotation = gunman.global_position.angle_to_point(area.global_position)
