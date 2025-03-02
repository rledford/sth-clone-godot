class_name Stronghold
extends Node2D

var _health: Health


func _ready() -> void:
	GunmanUpgrade.new().level_changed.connect(_handle_gunman_upgrade)
	_health = Health.new(100)
	_health.health_changed.connect(SignalBus.player_health_changed.emit)
	_health.died.connect(SignalBus.player_died.emit)

	RepairUpgrade.new(_health).level_changed.connect(_on_repair_level_changed)
	SignalBus.player_hit.connect(_on_player_hit)


func get_health() -> Health:
	return _health


func _handle_gunman_upgrade(_level: int):
	var gunman = Gunman.create()
	var posts = get_tree().get_nodes_in_group("gunman_posts") as Array[Node2D]
	var min_occupancy = (
		posts
		. map(func(p): return p.get_child_count())
		. reduce(func(min, value): return value if value < min else min)
	)

	(
		posts
		. filter(func(p): return p.get_child_count() <= min_occupancy)
		. pick_random()
		. add_child(gunman)
	)

	var target_areas = get_tree().get_nodes_in_group("enemy_spawn_areas") as Array[CollisionShape2D]
	var area: CollisionShape2D = target_areas.pick_random()
	gunman.rotation = gunman.global_position.angle_to_point(area.global_position)


func _on_player_hit(damage: int) -> void:
	_health.take_damage(damage)


func _on_repair_level_changed(_level: int) -> void:
	_health.heal(20)
