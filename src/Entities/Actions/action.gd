class_name Action
extends RefCounted

# Declare variables for the entity and cooldown
var entity: Entity
var timer: float

# Initialize the Action with an entity and set the initial cooldown
func _init(entity: Entity) -> void:
	self.entity = entity
	self.timer = 0

# Perform the action, returns false by default
func perform() -> bool:
	return false

# Get the map data from the entity
func get_map_data() -> MapData:
	return entity.map_data
