class_name Turret
extends Node2D

@export var damage: int = 1.0
@export var fire_rate: float = 0.25
@export var detection_radius: float = 120.0
@export var heat_threshold: float = 120.0
@export var heat_per_shot: float = 40.0
@export var heat_dissipation: float = 40.0  # heat dissipated per second
@export var rest_rotation_degrees: float = -180.0

var _last_fire_time: int = 0
var _heat_level: float = 0.0
var _is_overheated: bool = false
var _is_active: bool = false
var _target: EnemyAlt
var _heat_level_bar_size: Vector2

@onready var heat_level_bar: ColorRect = $HeatBar/HeatLevel
@onready var heat_level_bar_bg: ColorRect = $HeatBar/Background
@onready var heat_bar: Node2D = $HeatBar
@onready var light: PointLight2D = $Light
@onready var _muzzle_fire_particle: CPUParticles2D = $MuzzleFireParticle
@onready var _gun_shot_sfx: AudioStreamPlayer2D = $GunShotSFX


func _ready():
	self._heat_level_bar_size = Vector2(self.heat_level_bar_bg.get_rect().size)
	self.rotation = deg_to_rad(self.rest_rotation_degrees)
	self.light.texture_scale = 2 * (1 / (self.light.texture.get_size().x / self.detection_radius))
	_muzzle_fire_particle.one_shot = true
	_muzzle_fire_particle.emitting = false


func activate():
	self._is_active = true
	self.queue_redraw()


func _physics_process(delta: float) -> void:
	if not self._is_active:
		return

	self._update_heat(delta)

	if not self._target:
		self._acquire_target()

	self._aim(delta)

	if self._can_fire():
		self._fire()

	# keep heat bar orientation vertical
	heat_bar.set_rotation(-self.rotation + PI)


func _update_heat(delta):
	self._heat_level = max(0.0, self._heat_level - (delta * self.heat_dissipation))

	if is_zero_approx(self._heat_level) and self._is_overheated:
		self._is_overheated = false

	heat_level_bar.size.y = min(
		ceil(float(self._heat_level) / float(self.heat_threshold) * self._heat_level_bar_size.y),
		self._heat_level_bar_size.y
	)


func _acquire_target() -> void:
	var closest_enemy = (get_tree().get_nodes_in_group("enemies")).reduce(self._closest_enemy)

	if closest_enemy and self._is_in_range(closest_enemy):
		self._target = closest_enemy
		self._target.died.connect(self._on_target_died)


func _is_in_range(other: Node2D):
	var dist = self.global_position.distance_to(other.global_position)

	return dist <= self.detection_radius


func _closest_enemy(a: EnemyAlt, b: EnemyAlt) -> EnemyAlt:
	var a_dist = global_position.distance_squared_to(a.global_position)
	var b_dist = global_position.distance_squared_to(b.global_position)

	return a if a_dist < b_dist else b


func _aim(delta: float) -> void:
	# slower rotation change when overheated
	var delta_scale = 0.25 if (not self._target or self._is_overheated) else 1.0
	var target_rotation = deg_to_rad(self.rest_rotation_degrees)

	if self._target:
		target_rotation = self.global_position.angle_to_point(self._target.global_position)

	self.rotation = rotate_toward(self.rotation, target_rotation, delta * delta_scale * 1.8)


func _fire() -> void:
	self._heat_level = min(self._heat_level + self.heat_per_shot, self.heat_threshold)

	if self._heat_level >= self.heat_threshold:
		self._is_overheated = true

	_muzzle_fire_particle.restart()
	_muzzle_fire_particle.emitting = true
	_gun_shot_sfx.play()
	self._target.hit.emit(self.damage)
	self._last_fire_time = Time.get_ticks_msec()


func _can_fire() -> bool:
	return self._has_fire_time_elapsed() and self._is_target_in_view()


func _is_target_in_view() -> bool:
	if not self._target:
		return false

	var target_rotation = self.global_position.angle_to_point(self._target.global_position)
	var aiming_angle = lerp_angle(self.rotation, target_rotation, 1)

	return abs(self.rotation - aiming_angle) <= 0.05


func _has_fire_time_elapsed() -> bool:
	return Time.get_ticks_msec() - self._last_fire_time >= (self.fire_rate * 1000)


func _on_target_died() -> void:
	self._target = null
	self._acquire_target()


func _draw() -> void:  # see docs for how _draw is cached
	pass
	#if not self._is_active:
	#self.modulate.a = 0.33
	#draw_circle(Vector2.ZERO, self.detection_radius, Color.CYAN)
	#else:
	#self.modulate.a = 1.0
	#draw_circle(Vector2.ZERO, self.detection_radius, Color.RED, false)
