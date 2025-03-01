class_name PlayerMagazine
extends Magazine


func _init(ammo: int, max_ammo: int) -> void:
	super(ammo, max_ammo)

	self.ammo_changed.connect(SignalBus.player_ammo_changed.emit)

	ClipSizeUpgrade.new().level_changed.connect(_handle_clip_size_upgrade)


func _handle_clip_size_upgrade(level: int):
	var max_ammo = 7 + level
	self.change_size(max_ammo)
