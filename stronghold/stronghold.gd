class_name Stronghold
extends Node2D

var _health: Health
var _base_health: int = 100
var _upgrade: StrongholdUpgrade
var _occupant_slot_progression: Array[int] = [5, 12, 21]
var _occupants: Array[String] = []

@onready var occupants: Node = $Occupants
@onready var sprites: Node2D = $Sprites


func _ready() -> void:
	_health = Health.new(_base_health)
	_health.health_changed.connect(SignalBus.player_health_changed.emit)
	_health.died.connect(SignalBus.player_died.emit)

	_upgrade = StrongholdUpgrade.new()
	_upgrade.level_changed.connect(_handle_stronghold_upgrade)
	GunmanUpgrade.new().level_changed.connect(_handle_gunman_upgrade)
	RepairmanUpgrade.new().level_changed.connect(_on_repairman_upgraded)
	RepairUpgrade.new(_health).level_changed.connect(_on_repair_level_changed)
	SignalBus.player_hit.connect(_on_player_hit)

	self._update_sprite()


func get_health() -> Health:
	return _health


func get_occupants() -> Array[String]:
	return _occupants.duplicate()


func restore_occupants(occupant_data: Array) -> void:
	for occupant in occupant_data:
		_add_occupant(occupant)

	_check_vacancy()


func _handle_stronghold_upgrade(_level: int):
	self._update_sprite()
	self._check_vacancy()


func _max_occupant_slots() -> int:
	return self._occupant_slot_progression[self._upgrade.get_level()]


func _handle_gunman_upgrade(_level: int):
	self._add_occupant("gunman")


func _update_sprite():
	var level_sprites = self.sprites.get_children()
	for i in range(self.sprites.get_child_count()):
		level_sprites[i].visible = i == self._upgrade.get_level()


func _check_vacancy():
	if _occupants.size() >= self._max_occupant_slots():
		SignalBus.stronghold_full.emit()
	else:
		SignalBus.stronghold_vacant.emit()


func create_occupant(type: String) -> Node:
	match type:
		"gunman":
			return Gunman.create()
		"repairman":
			return Repairman.create(_health)
	return null


func _add_occupant(type: String) -> void:
	var max_slots = self._max_occupant_slots()
	var slots = occupants.get_children().slice(0, max_slots)

	for i in range(len(slots)):
		if len(slots[i].get_children()) == 0:
			slots[i].add_child(create_occupant(type))
			_occupants.append(type)
			break

	_check_vacancy()


func _on_player_hit(damage: int) -> void:
	_health.take_damage(damage)


func _on_repair_level_changed(_level: int) -> void:
	_health.heal(20)


func _on_repairman_upgraded(_level: int) -> void:
	self._add_occupant("repairman")
