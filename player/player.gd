class_name Player
extends Node2D

const Scene = preload("res://player/player.tscn")

var _weapons: Dictionary = {}

var _weapon: Weapon

var _fire_rate_upgrade: FireRateUpgrade
var _clip_size_upgrade: ClipSizeUpgrade

var _uzi_upgrade: UziUpgrade
var _shotgun_upgrade: ShotgunUpgrade


static func create() -> Player:
	var instance = Scene.instantiate()
	return instance


func get_magazine() -> PlayerMagazine:
	return _weapon.get_magazine()


func get_available_weapons() -> Array:
	return _weapons.keys()


func get_current_weapon() -> String:
	return _weapon.weapon_name


func _ready() -> void:
	self.add_to_group("player")

	_fire_rate_upgrade = FireRateUpgrade.new()
	_clip_size_upgrade = ClipSizeUpgrade.new()
	_uzi_upgrade = UziUpgrade.new()
	_shotgun_upgrade = ShotgunUpgrade.new()

	SignalBus.weapon_hotbar_clicked.connect(_on_weapon_hotbar_used)
	_uzi_upgrade.level_increased.connect(_on_uzi_purchase)
	_shotgun_upgrade.level_increased.connect(_on_shotgun_purchase)
	_unlock_weapon(Revolver.weapon_name)


func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	_weapon.point_to(global_position)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		_weapon.pull_trigger()
	elif event.is_action_released("shoot"):
		_weapon.release_trigger()
	elif event.is_action_pressed("reload"):
		_weapon.reload()


func _on_uzi_purchase() -> void:
	_unlock_weapon(Uzi.weapon_name)


func _on_shotgun_purchase() -> void:
	_unlock_weapon(Shotgun.weapon_name)


func _on_weapon_hotbar_used(weapon_name: String) -> void:
	_change_weapon(weapon_name)


func _change_weapon(weapon_name: String) -> void:
	if _weapons.has(weapon_name):
		_weapon = _weapons[weapon_name]
		SignalBus.weapon_changed.emit(weapon_name)
	else:
		print("Attempted to change to locked or invalid weapon" + weapon_name)
		return


func _unlock_weapon(weapon_name: String):
	var new_weapon: Weapon

	match weapon_name:
		Revolver.weapon_name:
			new_weapon = Revolver.create(_fire_rate_upgrade, _clip_size_upgrade)
		Uzi.weapon_name:
			new_weapon = Uzi.create(_fire_rate_upgrade, _clip_size_upgrade)
		Shotgun.weapon_name:
			new_weapon = Shotgun.create(_fire_rate_upgrade, _clip_size_upgrade)
		_:
			print("Attempted to unlock unknown weapon" + weapon_name)
			return

	add_child(new_weapon)
	_weapons[weapon_name] = new_weapon
	_weapon = new_weapon

	SignalBus.weapon_unlocked.emit(weapon_name)
	SignalBus.weapon_changed.emit(weapon_name)
