extends Resource
class_name UpgradeDefinition

@export var id: String
@export var name: String
@export var cost: int

func _init(_id: String, _name: String, _cost: int) -> void:
	self.id = _id
	self.name = _name
	self.cost = _cost

# NOTE: This class needs to change into being an "abstract upgrade", with the actual upgrades being subclasses of this class, sadly we don't have abstract classes or interfaces in GDScript, so we'll have to make do with this
# The upgrade system would have a way to "register" upgrades, so other systems can "push them out" to the menu, so they would own them and the upgrade system stays "simple"
static func get_all() -> Array:
	return [
		UpgradeDefinition.new("clip_size", "Clip Size", 10),
		UpgradeDefinition.new("fire_rate", "Fire Rate", 10),
	]
