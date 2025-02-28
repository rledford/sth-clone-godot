extends Control

# Ideally these would be calculated
const LEFT_OUTSIDE = Vector2(-480, 0)
const RIGHT_OUTSIDE = Vector2(480, 0)
const MIDDLE = Vector2(0, 0)

@onready var wave_announcement: Control = $"."


func _ready() -> void:
	animate()


func animate() -> void:
	wave_announcement.position = LEFT_OUTSIDE
	var tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(wave_announcement, "position", MIDDLE, 1)
	tween.tween_property(wave_announcement, "position", RIGHT_OUTSIDE, 1).set_delay(1.0)
