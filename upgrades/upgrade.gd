extends Resource
class_name UpgradeDefinition

@export var id: String
@export var name: String
@export var cost: int

func _init(_id: String, _name: String, _cost: int) -> void:
	self.id = _id
	self.name = _name
	self.cost = _cost

static func get_all() -> Array:
	return [
		UpgradeDefinition.new("clip_size", "Clip Size", 100),
		UpgradeDefinition.new("fire_rate", "Fire Rate", 100),
	]
