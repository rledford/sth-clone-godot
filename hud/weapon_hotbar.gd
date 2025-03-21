extends HBoxContainer

# Will need to listen to the player weapon changes and update the hotbar with the selected one
# Will need to keep track of which weapons are available, and keep the others hidden
# Will also need someway of getting the initial weapon


func _ready() -> void:
	var items = _get_items()
	items[0].set_selected(true)


func _get_items() -> Array[WeaponHotbarItem]:
	var items: Array[WeaponHotbarItem] = []
	var children = get_children()
	for child in children:
		if child is WeaponHotbarItem:
			items.append(child)
	return items
