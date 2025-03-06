class_name Tile
extends Sprite2D

# Variables to store tile properties and references
var tile_name: String
var _definition: TileDefinition
var player: Entity
var location_map: MapData

# Boolean with setter to track if the tile is explored
var is_explored: bool = false:
	set(value):
		is_explored = value
		# If the tile is explored and not visible, make it visible
		if is_explored and not visible:
			visible = true

# Boolean with setter to track if the tile is in view
var is_in_view: bool = false:
	set(value):
		is_in_view = value
		# Change the tile's color based on whether it is in view
		modulate = _definition.color_lit if is_in_view else _definition.color_dark
		# If the tile is in view and not explored, mark it as explored
		if is_in_view and not is_explored:
			is_explored = true

var key: TileTypes.TileKey

# Initialization function for tiles, setting up basic variables
func _init(entity: Entity, grid_position: Vector2i, key: TileTypes.TileKey) -> void:
	# Initially, the tile is not visible
	visible = false
	centered = false
	# Store the player entity reference
	player = entity
	# Set the tile's position based on the grid position
	position = Grid.grid_to_world(grid_position)
	# Set the tile type using the provided key
	set_tile_type(key)

# Function to set the tile type based on the dictionary definitions for each tile type
func set_tile_type(key: TileTypes.TileKey) -> void:
	self.key = key
	# Load the tile definition from the dictionary
	_definition = TileTypes.tile_definitions[key]
	# Set the tile's name, texture, and initial color
	tile_name = _definition.tile_name
	texture = _definition.texture
	modulate = _definition.color_dark
	# If the tile is not an overworld tile, set it as non-persistent
	if _definition.overworld_tile == false:
		_definition.persistent = false

# Function to check if the tile is an overworld tile
func is_overworld() -> bool:
	return _definition.overworld_tile

# Function to check if the tile is persistent
func is_persistent() -> bool:
	return _definition.persistent

# Function to check if the tile is walkable
func is_walkable() -> bool:
	return _definition.is_walkable

# Function to check if the tile is transparent
func is_transparent() -> bool:
	return _definition.is_transparent

# Function to get the grid position of the tile
func get_grid_position() -> Vector2i:
	return Grid.world_to_grid(position)

# Function to get the save data of the tile. Save data only includes data that is necessary to restore the tile to its current state, not static
func get_save_data() -> Dictionary:
	return {
		"key": key,
		"is_explored": is_explored,
	}

# Function to restore the tile from save data, the key will indicate everything else needed to restore the tile
func restore(save_data: Dictionary) -> void:
		set_tile_type(save_data["key"])
		is_explored = save_data["is_explored"]
