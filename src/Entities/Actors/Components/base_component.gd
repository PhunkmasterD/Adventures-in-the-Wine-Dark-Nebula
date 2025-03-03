class_name Component
extends Node

# Get the parent entity
@onready var entity: Entity = get_parent() as Entity

# Get the map data associated with the entity
func get_map_data() -> MapData:
	return entity.map_data
