class_name BottomUI
extends PanelContainer

const Scene = preload("res://hud/bottom_ui.tscn")

@onready var health_bar: ProgressBar = %HealthBar
@onready var health_bar_label: Label = %HealthBarLabel
@onready var ammo_bar: ProgressBar = %AmmoBar
@onready var ammo_bar_label: Label = %AmmoBarLabel
@onready var coin_label: Label = %CoinLabel
@onready var shop_btn: Button = %ShopButton
@onready var break_container: PanelContainer = %"Break Container"


func _ready() -> void:
	shop_btn.pressed.connect(func(): SignalBus.open_upgrade_menu.emit())

	SignalBus.coins_changed.connect(_handle_coins_changed)
	SignalBus.player_health_changed.connect(_handle_player_health_changed)
	SignalBus.player_ammo_changed.connect(_handle_player_ammo_changed)


func render(health: int, max_health: int, ammo: int, max_ammo: int, coins: int) -> void:
	_update_health(health, max_health)
	_update_coin_label(coins)
	ammo_bar.value = ammo
	ammo_bar.max_value = max_ammo
	update_ammo_bar_text()


func _handle_player_health_changed(health: int, max_health: int) -> void:
	_update_health(health, max_health)


func _handle_coins_changed(coins: int) -> void:
	_update_coin_label(coins)


func _handle_player_ammo_changed(ammo: int, max_ammo: int) -> void:
	ammo_bar.value = ammo
	ammo_bar.max_value = max_ammo

	update_ammo_bar_text()


func _update_coin_label(coins: int) -> void:
	coin_label.text = "%7d" % coins


func _update_health(health: int, max_health: int) -> void:
	health_bar.value = health
	health_bar.max_value = max_health
	health_bar_label.text = str(health) + "/" + str(max_health)


func update_ammo_bar_text() -> void:
	ammo_bar_label.text = str(ammo_bar.value) + "/" + str(ammo_bar.max_value)
