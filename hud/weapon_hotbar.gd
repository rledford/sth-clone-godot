extends HBoxContainer

# ✅Listens to the player weapon changes and update the hotbar with the selected one
# Will need to keep track of which weapons are available, and keep the others hidden
# Will also need someway of getting the initial weapon


func _ready() -> void:
	var items = _get_items()
	# TODO: This should be replaced with the current player weapon when we have that information
	items[0].set_selected(true)

	SignalBus.weapon_changed.connect(_on_weapon_changed)


func _on_weapon_changed(weapon_name: String) -> void:
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
