class_name TurretUpgrade
extends Upgrade

var is_enabled = true


func _init() -> void:
	name = "Turret"
	id = "turret"
	_category = UpgradeCategory.WEAPON
	priority = 100

	SignalBus.register_upgrade.emit(self)
	SignalBus.turret_placed.connect(_on_turret_placed)
	upgrade_purchased.connect(_on_upgrade_purchased)


func get_cost() -> int:
	return ceil(Scaling.exponential_growth(1200, 2.5, _level))


func can_buy() -> bool:
	return is_enabled


func _on_turret_placed(turret: Turret):
	turret.activate()
	self.is_enabled = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _increment_level() -> void:
	self.is_enabled = false
	super._increment_level()
