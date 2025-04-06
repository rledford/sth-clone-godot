class_name UpgradeMenuButton
extends PanelContainer

const Scene = preload("res://upgrades/menu/upgrade_menu_button.tscn")
const BuyText = 'BUY'
const MaxText = 'MAX'

var _upgrade: Upgrade
var _system: UpgradeSystem

@onready var name_label: Label = %UpgradeName
@onready var cost_label: Label = %UpgradeCost
@onready var buy_btn: Button = %UpgradeBuyButton


static func create(upgrade: Upgrade, system: UpgradeSystem) -> UpgradeMenuButton:
	var instance = Scene.instantiate()
	instance._upgrade = upgrade
	instance._system = system
	return instance


func _ready() -> void:
	update_values()
	buy_btn.pressed.connect(_on_buy)

	SignalBus.open_upgrade_menu.connect(update_values)
	SignalBus.upgrade_completed.connect(update_values)


func update_values() -> void:
	name_label.text = _upgrade.get_label()
	cost_label.text = String.num(_upgrade.get_cost())
	buy_btn.text = MaxText if _upgrade.is_maxed() else BuyText
	buy_btn.disabled = not _system.can_afford(_upgrade) or not _upgrade.can_buy()


func _on_buy() -> void:
	_system.attempt_upgrade(_upgrade)
