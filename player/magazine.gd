class_name PlayerMagazine
extends Magazine

var _base_ammo: int


func _init(base_ammo: int) -> void:
	super(base_ammo, base_ammo)
	_base_ammo = base_ammo

	self.ammo_changed.connect(SignalBus.player_ammo_changed.emit)

	ClipSizeUpgrade.new().level_changed.connect(_handle_clip_size_upgrade)


func _handle_clip_size_upgrade(level: int):
	var max_ammo = _base_ammo + level
	self.change_size(max_ammo)
