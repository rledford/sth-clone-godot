class_name Game
extends Node2D

const scene = preload("res://game.tscn")

# TODO: What relates to upgrades might be better placed in a separate class
# It might need to be placed as a sibling of Game, or above
# Due to wanting to pause the "Game" when the upgrade menu is open (Do we want this?)
var upgrades = UpgradeDefinition.get_all()

func create_upgrade_levels(_upgrades)->Dictionary:
	var result: Dictionary = {}
	for upgrade in _upgrades:
		result[upgrade.id] = 0
	return result

var _upgrade_levels = create_upgrade_levels(upgrades)

var _wave: int = 1
var _coins: int = 0
var _hud: HUD

static func create() -> Game:
	var instance = scene.instantiate()
	return instance

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	SignalBus.player_died.connect(_handle_player_died)
	SignalBus.enemy_died.connect(_handle_enemy_died)
	SignalBus.open_upgrade_menu.connect(_handle_open_upgrade_menu)
	
	var max_health = 100
	var health = max_health
	
	var max_ammo = 7
	var ammo = max_ammo

	var player = Player.create(health, max_health, ammo, max_ammo)
	add_child(player)

	_hud = HUD.create(health, max_health, ammo, max_ammo, _coins)
	add_child(_hud)

func _handle_player_died() -> void:
	SignalBus.game_over.emit(_wave)

func _handle_enemy_died(reward: int) -> void:
	_coins += reward
	SignalBus.coins_changed.emit(_coins)

func _handle_open_upgrade_menu() -> void:
	if get_tree().root.has_node("UpgradeMenu"): return
	
	# Creating the menu on the spot here, but it might be better to keep it around and hide/show it when needed?
	var upgrade_menu = UpgradeMenu.create()

	# Not exactly sure if we should be hiding the HUD, we shuffle the menu around to keep it visible, since the information is still relevant
	_hud.hide()
	
	get_tree().root.add_child(upgrade_menu)

	SignalBus.close_upgrade_menu.connect(func(): _hud.show() )
	SignalBus.upgrade_purchased.connect(_handle_upgrade_purchased)

func _handle_upgrade_purchased(upgrade: UpgradeDefinition) -> void:
	print("upgrade purchased ", upgrade.id)
