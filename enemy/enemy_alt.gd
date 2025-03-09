class_name EnemyAlt
extends CharacterBody2D

signal hit(damage: float)
signal died

@export var hitbox: CollisionShape2D
@export var sensor: Area2D
@export var anim: AnimatedSprite2D
@export var hit_particle: Resource
@export var hit_particle_color: Color
@export var attack_sfx: AudioStreamPlayer2D

@export var health: int = 2
@export var damage: int = 1
@export var speed: float = 100.0
@export var coin_reward: int = 1

var _attack_position = Vector2.INF
var _update_fn: Callable


func is_alive() -> bool:
	return health > 0


func set_difficulty(difficulty: float) -> void:
	health += ceil(difficulty)
	damage += ceil(difficulty * 0.5)
	speed += ceil(difficulty * 0.5)
	coin_reward += floor(difficulty * 1.5)


func _ready() -> void:
	anim.animation_finished.connect(_on_animation_finished)
	anim.animation_looped.connect(_on_animation_finished)
	sensor.area_entered.connect(_on_area_2d_area_entered)
	sensor.area_exited.connect(_on_area_2d_area_exited)


func _physics_process(delta: float) -> void:
	if not _update_fn:
		return

	_update_fn.call(delta)


func _update_idle(delta: float) -> void:
	_find_target()
	if _has_valid_target():
		_update_fn = _update_move
		return 
	
	if anim.animation != 'idle':
		anim.play('idle')


func _update_move(delta: float) -> void:
	if not _has_valid_target():
		_update_fn = _update_idle
		return

	if anim.animation != 'move':
		anim.play('move')

	velocity = (_attack_position - hitbox.global_position).normalized() * speed
	move_and_slide()
	_flip()


func _update_attack(delta: float) -> void:
	if not _has_valid_target():
		_update_fn = _update_idle
		return
	
	if anim.animation != 'attack':
		anim.play('attack')


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


func _on_hit(_amount: int) -> void:
	var particle = hit_particle.instantiate() as CPUParticles2D
	particle.color = hit_particle_color
	particle.one_shot = true

	add_child(particle)

	health -= _amount
	if not is_alive():
		particle.finished.connect(queue_free)
		died.emit()


func _enter_tree() -> void:
	_update_fn = _update_idle
	hit.connect(_on_hit)
	died.connect(_on_died)


func _on_area_2d_area_entered(_area: Area2D) -> void:
	_update_fn = _update_attack


func _on_area_2d_area_exited(_area: Area2D) -> void:
	if is_alive():
		_update_fn = _update_idle


func _on_died() -> void:
	SignalBus.enemy_died.emit(coin_reward)
	remove_from_group("enemies")
	_update_fn = _update_death
	hitbox.disabled = true
	anim.visible = false


func _on_animation_finished() -> void:
	if anim.animation != 'attack':
		return
	else:
		if attack_sfx and not attack_sfx.playing:
			attack_sfx.play()

	SignalBus.player_hit.emit(self.damage)


func _is_collision_shape(area) -> bool:
	return area is CollisionShape2D
