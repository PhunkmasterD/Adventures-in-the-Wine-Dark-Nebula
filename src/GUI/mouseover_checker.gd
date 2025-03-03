extends Node2D

signal entities_focussed(entity_list)

@onready var map: Map = get_parent()

# Process function to check for mouseover events
func _process(_delta: float) -> void:
	# Get the mouse position in local coordinates
	var mouse_position: Vector2 = get_local_mouse_position()
	# Convert the mouse position to grid coordinates
	var tile_position: Vector2i = Grid.world_to_grid(mouse_position)
	# Get the names of entities at the mouse position
	var entity_names = get_names_at_location(tile_position)
	# Emit the entities_focussed signal with the entity names
	entities_focussed.emit(entity_names)

# Function to get the names of entities at a specific grid position
func get_names_at_location(grid_position: Vector2i) -> String:
	var entity_names := ""
	var map_data: MapData = map.map_data
	# Get the tile at the specified grid position
	var tile: Tile = map_data.get_tile(grid_position)
	# Return an empty string if the tile is not in view
	if not tile or not tile.is_in_view:
		return entity_names
	# Collect all entities at the specified grid position
	var entities_at_location: Array[Entity] = []
	for entity in map_data.entities:
		if entity.grid_position == grid_position:
			entities_at_location.append(entity)
	# Sort the entities by their z_index
	entities_at_location.sort_custom(func(a, b): return a.z_index > b.z_index)
	# Concatenate the names of the entities
	if not entities_at_location.is_empty():
		entity_names = entities_at_location[0].get_entity_name()
		for i in range(1, entities_at_location.size()):
			entity_names += ", %s" % entities_at_location[i].get_entity_name()
	return entity_names
