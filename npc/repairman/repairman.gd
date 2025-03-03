class_name Repairman
extends Node2D

var repair_amount: int = 1
var repair_delay: float = 1.0

var _health: Health
var _is_repairing: bool = false


func _init(health: Health) -> void:
	print("[Repairman] Created")
	_health = health
	_health.took_damage.connect(_on_damage_taken)


func _ready() -> void:
	act()


func act() -> void:
	if _health.is_full():
		print("[Repairman] Health is full, stopping repair")
		_is_repairing = false
		return

	_is_repairing = true

	await repair()

	act()


func repair() -> void:
	print("[Repairman] Repairing")
	_health.heal(repair_amount)
	await get_tree().create_timer(repair_delay).timeout


func _on_damage_taken() -> void:
	if not _is_repairing:
		act()
