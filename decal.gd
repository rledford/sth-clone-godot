extends TileMapLayer

const LampLight = preload("res://lamp_light.tscn")


func _ready() -> void:
	var cells = self.get_used_cells()

	var light_sources = cells.filter(
		func(cell):
			var data = self.get_cell_tile_data(cell)
			return data.get_custom_data("light") == true
	)

	for cell in light_sources:
		var light = LampLight.instantiate()
		var pos = self.map_to_local(cell)
		light.set_position(pos)
		self.add_child(light)
