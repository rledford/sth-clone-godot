extends PanelContainer
class_name UpgradeMenuButton

@onready var name_label: Label = %UpgradeName
@onready var cost_label: Label = %UpgradeCost
@onready var buy_btn: Button = %UpgradeBuyButton

const scene = preload("res://upgrades/menu/upgrade_menu_button.tscn")

var _upgrade: Upgrade

static func create(upgrade: Upgrade) -> UpgradeMenuButton:
	var instance = scene.instantiate()
	instance._upgrade = upgrade
	return instance

func _ready() -> void:
	update_values()
	buy_btn.pressed.connect(_on_buy)

	_upgrade.level_increase.connect(update_values)
	SignalBus.open_upgrade_menu.connect(update_values)

# Should somehow get the current coin count to disable/enable the button
func update_values() -> void:
	name_label.text = _upgrade.getLabel()
	cost_label.text = String.num(_upgrade.getCost())

func _on_buy() -> void:
	SignalBus.attempt_upgrade.emit(_upgrade)
