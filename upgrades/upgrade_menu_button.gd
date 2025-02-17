extends PanelContainer
class_name UpgradeMenuButton

@onready var name_label: Label = %UpgradeName
@onready var cost_label: Label = %UpgradeCost
@onready var buy_btn: Button = %UpgradeBuyButton

const scene = preload("res://upgrades/upgrade_menu_button.tscn")

var _upgrade: UpgradeDefinition

static func create(upgrade: UpgradeDefinition) -> UpgradeMenuButton:
	var instance = scene.instantiate()
	instance._upgrade = upgrade
	return instance

func _ready() -> void:
	name_label.text = _upgrade.name
	cost_label.text = String.num(_upgrade.cost)
	buy_btn.pressed.connect(_on_buy)

func _on_buy() -> void:
	SignalBus.upgrade_purchased.emit(_upgrade)
