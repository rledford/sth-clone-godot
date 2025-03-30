class_name PlayerMagazine
extends Magazine


func _init(
	base_ammo: int,
) -> void:
	super(base_ammo, base_ammo)

	self.ammo_changed.connect(SignalBus.player_ammo_changed.emit)
