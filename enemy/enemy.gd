class_name Enemy
extends CharacterBody2D

signal hit(damage: float)
signal died

@export var coin_reward: int = 1
@export var hp: int = 2
@export var damage: int = 1
@export var speed: float = 100.0

var attack_position = Vector2.INF
var hit_particle = preload("res://particles/enemy_hit_particle.tscn")
var hit_particle_color: Color = Color.RED
var fsm: StateMachine


func filter_attack_areas(area) -> bool:
	return area is CollisionShape2D


func _update_attack_position() -> void:
	var areas = (
		get_tree().get_nodes_in_group("attack_areas").filter(filter_attack_areas)
		as Array[CollisionShape2D]
	)
	var target = areas.pick_random() as CollisionShape2D
	if not target:
		attack_position = Vector2.INF
		return
	var target_size = target.shape.get_rect().size as Vector2
	var rand_x = target.global_position.x - (target_size.x * 0.5)

	var rand_y = clamp(
		global_position.y,
		target.global_position.y - (target_size.y * 0.5),
		target.global_position.y + (target_size.y * 0.5)
	)

	attack_position = Vector2(rand_x, rand_y)


func has_valid_attack_position() -> bool:
	return attack_position and attack_position != Vector2.INF


func attack_anim_finished() -> void:
	if hp <= 0:
		print("shouldn't be attacking when dead")
	else:
		SignalBus.player_hit.emit(damage)


func flip() -> void:
	if velocity.x > 0.0:
		scale.x = scale.y * 1
	elif velocity.x < -0.0:
		scale.x = scale.y * -1


func _handle_hit(_amount: int) -> void:
	hp -= _amount
	if hp <= 0:
		fsm.change_state("death")

	var particle = hit_particle.instantiate() as CPUParticles2D
	particle.color = hit_particle_color
	particle.one_shot = true
	add_child(particle)


func _enter_tree() -> void:
	hit.connect(_handle_hit)
	died.connect(_handle_died)


func _on_area_2d_area_entered(_area: Area2D) -> void:
	fsm.change_state("attack")


func _on_area_2d_area_exited(_area: Area2D) -> void:
	fsm.change_state("idle")


func _handle_died() -> void:
	remove_from_group("enemies")
