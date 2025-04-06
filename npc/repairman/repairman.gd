class_name Repairman
extends Node2D

const Scene = preload("res://npc/repairman/repairman.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var heal_particle: CPUParticles2D = $HealParticle

var repair_amount: int = 1
var repair_delay: float = 1.0

var _health: Health
var _is_repairing: bool = false

static func create(health: Health) -> Repairman:
	var instance = Scene.instantiate()
	instance._health = health
	instance._health.took_damage.connect(instance._on_damage_taken)
	return instance


func _ready() -> void:
	self.animation_player.play('default')
	self.heal_particle.emitting = false
	act()


func act() -> void:
	if _health.is_full():
		print("[Repairman] Health is full, stopping repair")
		_is_repairing = false
		self.heal_particle.emitting = false
		return

	_is_repairing = true
	self.heal_particle.emitting = true

	await repair()

	act()


func repair() -> void:
	print("[Repairman] Repairing")
	_health.heal(repair_amount)
	await get_tree().create_timer(repair_delay).timeout


func _on_damage_taken() -> void:
	if not _is_repairing:
		act()
