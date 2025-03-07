class_name PlayerMagazine
extends Magazine

var _base_ammo: int
var _clip_size_bonus_ratio: float


func _init(
	base_ammo: int, clip_size_upgrade: ClipSizeUpgrade, clip_size_bonus_ratio: float
) -> void:
	_base_ammo = base_ammo
	_clip_size_bonus_ratio = clip_size_bonus_ratio
	var total_ammo = _get_total_ammo(clip_size_upgrade.get_level(), clip_size_bonus_ratio)
	super(total_ammo, total_ammo)

	self.ammo_changed.connect(SignalBus.player_ammo_changed.emit)
	clip_size_upgrade.level_changed.connect(_on_clip_size_upgrade)


func _on_clip_size_upgrade(level: int):
	var max_ammo = _get_total_ammo(level, _clip_size_bonus_ratio)
	self.change_size(max_ammo)


func _get_total_ammo(upgrade_level: int, ratio: float) -> int:
	var bonus = floor(upgrade_level * ratio)
	return _base_ammo + bonus
