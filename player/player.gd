class_name Player
extends Node2D

const Scene = preload("res://player/player.tscn")
const TurretScene = preload("res://npc/turret/turret.tscn")

var _weapons: Dictionary = {}

var _weapon: Weapon

var _uzi_upgrade: UziUpgrade
var _shotgun_upgrade: ShotgunUpgrade
var _turret_upgrade: TurretUpgrade

var _turret_to_place: Turret = null


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

	_uzi_upgrade = UziUpgrade.new()
	_shotgun_upgrade = ShotgunUpgrade.new()
	_turret_upgrade = TurretUpgrade.new()

	SignalBus.weapon_hotbar_clicked.connect(_on_weapon_hotbar_used)
	_uzi_upgrade.level_increased.connect(_on_uzi_purchase)
	_shotgun_upgrade.level_increased.connect(_on_shotgun_purchase)
	_turret_upgrade.level_increased.connect(_on_turret_purchase)
	_unlock_weapon(Revolver.weapon_name)


func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	_weapon.point_to(global_position)
	if _turret_to_place != null:
		_turret_to_place.global_position = get_global_mouse_position()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		if _turret_to_place:
			SignalBus.turret_placed.emit(self._turret_to_place)
			self._turret_to_place = null
		else:
			_weapon.pull_trigger()
	elif event.is_action_released("shoot"):
		_weapon.release_trigger()
	elif event.is_action_pressed("reload"):
		_weapon.reload()


func _on_uzi_purchase() -> void:
	_unlock_weapon(Uzi.weapon_name)


func _on_shotgun_purchase() -> void:
	_unlock_weapon(Shotgun.weapon_name)


func _on_turret_purchase() -> void:
	var turret = TurretScene.instantiate()
	var turret_group = get_tree().get_nodes_in_group("turrets") as Array[Node2D]

	if len(turret_group) == 0:
		push_error("at least one node in the 'turrets' group must exist for turrets to added to")

	self._turret_to_place = turret

	turret_group[0].add_child(turret)
	SignalBus.close_upgrade_menu.emit()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	


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
			new_weapon = Revolver.create()
		Uzi.weapon_name:
			new_weapon = Uzi.create(_uzi_upgrade)
		Shotgun.weapon_name:
			new_weapon = Shotgun.create(_shotgun_upgrade)
		_:
			print("Attempted to unlock unknown weapon" + weapon_name)
			return

	add_child(new_weapon)
	_weapons[weapon_name] = new_weapon
	_weapon = new_weapon

	SignalBus.weapon_unlocked.emit(weapon_name)
	SignalBus.weapon_changed.emit(weapon_name)
