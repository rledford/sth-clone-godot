extends HBoxContainer


func _ready() -> void:
	var player = _get_player()

	if player:
		_set_weapon_visibility(player.get_available_weapons())
		_set_selected_weapon(player.get_current_weapon())

	SignalBus.weapon_changed.connect(_on_weapon_changed)
	SignalBus.weapon_unlocked.connect(_on_weapon_unlocked)


func _on_weapon_changed(weapon_name: String) -> void:
	_set_selected_weapon(weapon_name)


func _on_weapon_unlocked(_name: String) -> void:
	var player = _get_player()
	if player:
		_set_weapon_visibility(player.get_available_weapons())


func _set_weapon_visibility(available: Array) -> void:
	var items = _get_items()
	for item in items:
		if available.has(item.weapon_name):
			item.set_visible(true)
		else:
			item.set_visible(false)


func _set_selected_weapon(weapon_name: String) -> void:
	var items = _get_items()
	for item in items:
		if item.weapon_name == weapon_name:
			item.set_selected(true)
		else:
			item.set_selected(false)


func _get_items() -> Array[WeaponHotbarItem]:
	var items: Array[WeaponHotbarItem] = []
	var children = get_children()
	for child in children:
		if child is WeaponHotbarItem:
			items.append(child)
	return items


## Can return null!
func _get_player() -> Player:
	var nodes = self.get_tree().get_nodes_in_group("player")
	if nodes.size() == 0:
		return null
	return nodes[0] as Player
