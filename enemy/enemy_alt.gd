class_name EnemyAlt
extends CharacterBody2D

signal hit(damage: float)
signal health_changed(current: int, max: int)
signal died
signal entered_attack_hit_frame
signal finished_attack_animation

# Stagger phase constants
const KNOCKBACK_PHASE_RATIO := 0.3  # First 30% of stagger time is knockback
const MOVEMENT_DISABLED_PHASE_RATIO := 0.7  # Can't move during first 70% of stagger

@export var hitbox: CollisionShape2D
@export var sensor: Area2D
@export var anim: AnimatedSprite2D
@export var hit_particle: Resource
@export var hit_particle_color: Color
@export var attack_sfx: AudioStreamPlayer2D
@export var attack_frame_index: int = 2
@export var health_bar: HealthBar

@export var max_health: int = 1
@export var damage: int = 1
@export var attack_speed: float = 2.5
@export var speed: float = 100.0
@export var coin_reward: int = 1
@export var stagger_resistance: float = 1.0  # Higher values reduce stagger effect

var _health: int
var _attack_position: Vector2 = Vector2.INF
var _last_attack_time: int = 0
var _is_attacking: bool = false
var _state: String = "idle"

# Stagger properties
var _is_staggered: bool = false
var _stagger_timer: float = 0.0
var _stagger_duration: float = 0.0
var _stagger_speed_penalty: float = 0.0
var _stagger_direction: Vector2 = Vector2.ZERO
var _original_speed: float = 0.0
var _knockback_force: float = 0.0


func is_alive() -> bool:
	return _health > 0


func can_attack() -> bool:
	var attack_time_delta = Time.get_ticks_msec() - _last_attack_time
	return (not _is_attacking) and attack_time_delta >= (attack_speed * 1000.0)


func can_move() -> bool:
	if not _is_staggered:
		return true

	# Can only move in the later phase of stagger
	return _stagger_timer <= (_stagger_duration * (1.0 - MOVEMENT_DISABLED_PHASE_RATIO))


func _ready() -> void:
	entered_attack_hit_frame.connect(_on_entered_attack_hit_frame)
	finished_attack_animation.connect(_on_finished_attack_animation)
	anim.frame_changed.connect(_on_animation_frame_changed)
	sensor.area_entered.connect(_on_area_2d_area_entered)
	sensor.area_exited.connect(_on_area_2d_area_exited)
	_health = max_health
	_original_speed = speed

	if health_bar:
		health_changed.connect(health_bar._on_change)

	health_changed.emit(_health, max_health)


func _physics_process(delta: float) -> void:
	if _is_staggered:
		_update_stagger(delta)

	match _state:
		"idle":
			_update_idle(delta)
		"move":
			_update_move(delta)
		"attack":
			_update_attack(delta)
		"death":
			_update_death(delta)


func _update_stagger(delta: float) -> void:
	_stagger_timer -= delta

	if _stagger_timer <= 0:
		_is_staggered = false
		speed = _original_speed
	else:
		var knockback_duration = _stagger_duration * KNOCKBACK_PHASE_RATIO
		if _stagger_timer > (_stagger_duration - knockback_duration):
			velocity = _stagger_direction * _knockback_force
			move_and_slide()

		speed = (
			_original_speed * (1.0 - _stagger_speed_penalty * (_stagger_timer / _stagger_duration))
		)


func _update_idle(_delta: float) -> void:
	_find_target()

	if anim.animation != "idle":
		anim.play("idle")

	if _has_valid_target() and can_move():
		_set_state("move")
		return


func _update_move(_delta: float) -> void:
	if anim.animation != "move":
		anim.play("move")

	if not _has_valid_target():
		_set_state("idle")
		return

	if can_move():
		velocity = (_attack_position - hitbox.global_position).normalized() * speed
		move_and_slide()
		_flip()


func _update_attack(_delta: float) -> void:
	if _is_attacking or not can_attack() or _is_staggered:
		return

	if not _has_valid_target():
		_set_state("idle")
		return

	_is_attacking = true
	anim.play("attack")


func _update_death(_delta: float) -> void:
	pass


func _find_target() -> void:
	var areas = (
		get_tree().get_nodes_in_group("attack_areas").filter(_is_collision_shape)
		as Array[CollisionShape2D]
	)
	var target = areas.pick_random() as CollisionShape2D
	if not target:
		_attack_position = Vector2.INF
		return
	var target_size = target.shape.get_rect().size as Vector2
	var rand_x = target.global_position.x - (target_size.x * 0.5)

	var rand_y = clamp(
		global_position.y,
		target.global_position.y - (target_size.y * 0.5),
		target.global_position.y + (target_size.y * 0.5)
	)

	_attack_position = Vector2(rand_x, rand_y)


func _has_valid_target() -> bool:
	return _attack_position and _attack_position != Vector2.INF


func _flip() -> void:
	if velocity.x > 0.0:
		scale.x = scale.y * 1
	elif velocity.x < -0.0:
		scale.x = scale.y * -1


func apply_stagger(damage_amount: int) -> void:
	var stagger_factor = damage_amount / max(stagger_resistance, 0.1)
	_stagger_duration = clamp(stagger_factor * 0.5, 0.5, 2.0)
	_stagger_speed_penalty = clamp(stagger_factor * 0.2, 0.1, 0.8)

	if _has_valid_target():
		var movement_dir = (_attack_position - hitbox.global_position).normalized()
		_stagger_direction = -movement_dir

	# Calculate knockback force based on damage and resistance
	_knockback_force = _original_speed * 1.5 * (damage_amount / (stagger_resistance + 1.0))

	# Ensure minimum knockback
	_knockback_force = max(_knockback_force, _original_speed * 0.5)

	_is_staggered = true
	_stagger_timer = _stagger_duration

	anim.modulate = Color(1.5, 1.5, 1.5)  # Flash white
	var tween = create_tween()
	tween.tween_property(anim, "modulate", Color(1, 1, 1), 0.3)


func _on_hit(amount: int) -> void:
	var particle = hit_particle.instantiate() as CPUParticles2D
	particle.color = hit_particle_color
	particle.one_shot = true

	add_child(particle)

	_health -= amount

	apply_stagger(amount)

	if not is_alive():
		particle.finished.connect(queue_free)
		died.emit()

	health_changed.emit(_health, max_health)


func _enter_tree() -> void:
	hit.connect(_on_hit)
	died.connect(_on_died)


func _on_area_2d_area_entered(_area: Area2D) -> void:
	if not _is_staggered:
		_set_state("attack")


func _on_area_2d_area_exited(_area: Area2D) -> void:
	if is_alive():
		_set_state("idle")


func _on_died() -> void:
	_set_state("death")
	SignalBus.enemy_died.emit(coin_reward)
	remove_from_group("enemies")
	anim.stop()
	hitbox.disabled = true
	anim.visible = false


func _on_animation_frame_changed() -> void:
	if anim.animation != "attack":
		return

	var attack_hit_frame_just_entered = anim.frame == attack_frame_index
	var attack_anim_finished = anim.frame == anim.sprite_frames.get_frame_count("attack") - 1

	if attack_hit_frame_just_entered:
		entered_attack_hit_frame.emit()

	if attack_anim_finished:
		finished_attack_animation.emit()


func _on_entered_attack_hit_frame() -> void:
	if attack_sfx and not attack_sfx.playing:
		attack_sfx.play()

	SignalBus.player_hit.emit(self.damage)


func _on_finished_attack_animation() -> void:
	_last_attack_time = Time.get_ticks_msec()
	_is_attacking = false
	anim.play("idle")


func _is_collision_shape(area) -> bool:
	return area is CollisionShape2D


func _set_state(state: String) -> void:
	assert(state in ["idle", "move", "attack", "death"])
	_state = state
