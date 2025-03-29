extends Projectile


func _on_collision(_area) -> void:
	SignalBus.player_hit.emit(damage)
	queue_free()
