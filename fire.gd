extends PointLight2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animate_energy()
	animate_size()


func animate_energy() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_loops()
	tween.tween_property(self, "energy", self.energy * 1.05, 0.25)
	tween.tween_property(self, "energy", self.energy * 0.95, 0.25)


func animate_size() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "texture_scale", self.texture_scale * 1.05, 3)
	tween.tween_property(self, "texture_scale", self.texture_scale * 0.95, 3)
