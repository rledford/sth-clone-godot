extends Node2D
class_name HealthBar

@onready var background: ColorRect = $Background
@onready var foreground: ColorRect = $Foreground

var _size: Vector2


func _ready() -> void:
	_size = Vector2(background.get_rect().size)
	foreground.set_size(_size)


func _on_change(current: int, max: int) -> void:
	foreground.size.x = min(ceil(float(current)/float(max) * _size.x), _size.x)
	visible = current > 0 and current < max
