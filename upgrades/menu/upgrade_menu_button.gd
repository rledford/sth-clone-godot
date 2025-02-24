class_name UpgradeMenuButton
extends PanelContainer

const Scene = preload("res://upgrades/menu/upgrade_menu_button.tscn")

var _upgrade: Upgrade

@onready var name_label: Label = %UpgradeName
@onready var cost_label: Label = %UpgradeCost
@onready var buy_btn: Button = %UpgradeBuyButton


static func create(upgrade: Upgrade) -> UpgradeMenuButton:
	var instance = Scene.instantiate()
	instance._upgrade = upgrade
	return instance


func _ready() -> void:
	update_values()
	buy_btn.pressed.connect(_on_buy)

	_upgrade.level_increase.connect(update_values)
	SignalBus.open_upgrade_menu.connect(update_values)


# Should somehow get the current coin count to disable/enable the button
func update_values() -> void:
	name_label.text = _upgrade.get_label()
	cost_label.text = String.num(_upgrade.get_cost())


func _on_buy() -> void:
	# This could be a local signal, and it should be past tense
	SignalBus.attempt_upgrade.emit(_upgrade)
