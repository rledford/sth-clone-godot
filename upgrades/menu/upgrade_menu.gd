class_name UpgradeMenu
extends CanvasLayer

const Scene = preload("res://upgrades/menu/upgrade_menu.tscn")

var _upgrade_system: UpgradeSystem
@onready var upgrades_grid: GridContainer = %UpgradesGrid
@onready var close_btn: Button = %CloseButton


static func create(upgrade_system: UpgradeSystem) -> UpgradeMenu:
	var instance = Scene.instantiate()
	instance._upgrade_system = upgrade_system
	return instance


func _ready() -> void:
	close_btn.pressed.connect(_on_close)
	var upgrades = _upgrade_system.get_upgrades()
	for upgrade in upgrades:
		var upgrade_item = UpgradeMenuButton.create(upgrade)
		upgrades_grid.add_child(upgrade_item)


func _on_close() -> void:
	# Rename signal to upgrade_menu_closed, and it could also be a local one
	SignalBus.close_upgrade_menu.emit()
