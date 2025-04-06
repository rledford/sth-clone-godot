class_name Stronghold
extends Node2D

@onready var occupants: Node = $Occupants
@onready var sprites: Node2D = $Sprites

var _health: Health
var _level: int = 0
var _max_level: int = 3
var _base_health: int = 100
var _current_occupants: int = 0
var _occupant_slot_progression: Array[int] = [5,12,21]


func _ready() -> void:
	_health = Health.new(_base_health)
	_health.health_changed.connect(SignalBus.player_health_changed.emit)
	_health.died.connect(SignalBus.player_died.emit)

	GunmanUpgrade.new().level_changed.connect(_handle_gunman_upgrade)
	StrongholdUpgrade.new().level_changed.connect(_handle_stronghold_upgrade)
	RepairmanUpgrade.new().level_changed.connect(_on_repairman_upgraded)
	RepairUpgrade.new(_health).level_changed.connect(_on_repair_level_changed)
	SignalBus.player_hit.connect(_on_player_hit)

	self._update_sprite()


func get_health() -> Health:
	return _health


func _handle_stronghold_upgrade(_level: int):
	self._level = _level
	self._update_sprite()
	self._check_vacancy()


func _max_occupant_slots() -> int:
	return self._occupant_slot_progression[self._level]


func _handle_gunman_upgrade(_level: int):
	var target_areas = get_tree().get_nodes_in_group("enemy_spawn_areas") as Array[CollisionShape2D]
	var area: CollisionShape2D = target_areas.pick_random()
	
	var gunman = Gunman.create()
	gunman.rotation = gunman.global_position.angle_to_point(area.global_position)
	
	self._add_occupant(gunman)


func _update_sprite():
	var level_sprites = self.sprites.get_children()
	for i in range(self.sprites.get_child_count()):
		level_sprites[i].visible = i == self._level


func _check_vacancy():
	if self._current_occupants >= self._max_occupant_slots():
		SignalBus.stronghold_full.emit()
	else:
		SignalBus.stronghold_vacant.emit()

func _add_occupant(entity):
	var max_slots = self._max_occupant_slots()
	var slots = occupants.get_children().slice(0, max_slots)
	
	for i in range(len(slots)):
		if len(slots[i].get_children()) == 0:
			slots[i].add_child(entity)
			self._current_occupants += 1
			break
	
	_check_vacancy()


func _on_player_hit(damage: int) -> void:
	_health.take_damage(damage)


func _on_repair_level_changed(_level: int) -> void:
	_health.heal(20)


func _on_repairman_upgraded(_level: int) -> void:
	self._add_occupant(Repairman.create(_health))
