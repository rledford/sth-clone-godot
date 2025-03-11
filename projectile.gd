extends Node2D
class_name Projectile


@export var sensor: Area2D
@export var speed: float = 100.0
@export var damage: int = 1
@export var lifetime: int = 10

var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	SignalBus.player_died.connect(queue_free)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
	
	if not sensor:
		print("no sensor")
		return

	sensor.area_entered.connect(_on_collision)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	

func _on_collision(_area) -> void:
	print("_on_collision not implemented")
	queue_free()
