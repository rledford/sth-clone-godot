class_name HUD
extends CanvasLayer

@onready var health_bar: ProgressBar = %HealthBar
@onready var health_bar_label: Label = %HealthBarLabel
@onready var ammo_bar: ProgressBar = %AmmoBar
@onready var ammo_bar_label: Label = %AmmoBarLabel
@onready var coin_label: Label = %CoinLabel
@onready var shop_btn: Button = %ShopButton

const scene = preload("res://hud/hud.tscn")

var _init_health: int
var _init_max_health: int

var _init_ammo: int
var _init_max_ammo: int

var _init_coins: int

static func create(health: int, max_health: int, ammo: int, max_ammo: int, coins:int) -> HUD:
	var instance = scene.instantiate()
	
	instance._init_health = health
	instance._init_max_health = max_health
	
	instance._init_ammo = ammo
	instance._init_max_ammo = max_ammo

	instance._init_coins = coins
	
	return instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_health(_init_health, _init_max_health)
	
	ammo_bar.value = _init_ammo
	ammo_bar.max_value = _init_max_ammo
	update_ammo_bar_text()

	shop_btn.pressed.connect(func(): SignalBus.open_upgrade_menu.emit() )

	_update_coin_label(_init_coins)
	SignalBus.coins_changed.connect(_handle_coins_changed)
	SignalBus.player_health_changed.connect(_handle_player_health_changed)
	SignalBus.player_ammo_changed.connect(_handle_player_ammo_changed)

func _handle_player_health_changed(health: int, max_health: int) -> void:
	_update_health(health, max_health)

func _handle_coins_changed(coins: int) -> void:
	_update_coin_label(coins)
	
func _handle_player_ammo_changed(ammo: int, max_ammo: int) -> void:
	ammo_bar.value = ammo
	ammo_bar.max_value = max_ammo
	
	update_ammo_bar_text()

func _update_coin_label(coins:int) -> void:
	coin_label.text = "COINS: %7d" % coins

func _update_health(health:int, max_health:int) -> void:
	health_bar.value = health
	health_bar.max_value = max_health
	health_bar_label.text = str(health) + " / " + str(max_health)

func update_ammo_bar_text() -> void:
	ammo_bar_label.text = str(ammo_bar.value) + " / " + str(ammo_bar.max_value)
