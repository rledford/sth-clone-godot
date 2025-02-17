extends Control
class_name UpgradeMenu

@onready var upgrades_grid: GridContainer = %UpgradesGrid
@onready var close_btn: Button = %CloseButton
const scene = preload("res://upgrades/upgrade_menu.tscn")

static func create() -> UpgradeMenu:
	var instance = scene.instantiate()
	return instance

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	close_btn.pressed.connect(_on_close)
	var upgrades = UpgradeDefinition.get_all()
	for upgrade in upgrades:
		var upgrade_item = UpgradeMenuButton.create(upgrade)
		upgrades_grid.add_child(upgrade_item)

func _on_close() -> void:
	SignalBus.close_upgrade_menu.emit()
	self.queue_free()

func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
