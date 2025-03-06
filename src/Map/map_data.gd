class_name MapData
extends RefCounted


# Signal for entity placement
signal entity_placed(entity)

# Constants and variables for map data
const entity_pathfinding_weight = 10.0

var coordinates: Vector3i
var persistent: bool = false
var width: int
var height: int
var tiles: Array[Tile]
var entities: Array[Entity]
var player: Entity
var down_stairs_location: Vector2i
var pathfinder: AStarGrid2D

# Initialization function
func _init(world_coordinates: Vector3i, map_width: int, map_height: int, player: Entity, persistent_flag: bool = false) -> void:
	# Set initial map properties
	coordinates = world_coordinates
	persistent = persistent_flag
	width = map_width
	height = map_height
	self.player = player
	entities = []
	# Set up the tiles for the map
	_setup_tiles()

# Function to set up array of generic tiles across the map
func _setup_tiles() -> void:
	tiles = []
	# Create a grid of tiles
	for y in height:
		for x in width:
			var tile_position := Vector2i(x, y)
			# Initialize each tile as a wall
			var tile := Tile.new(player, tile_position, TileTypes.TileKey.FOREST)
			tiles.append(tile)

# Function to check if a coordinate is in bounds
func is_in_bounds(coordinate: Vector2i) -> bool:
	return (
		0 <= coordinate.x
		and coordinate.x < width
		and 0 <= coordinate.y
		and coordinate.y < height
	)

# Function to get a tile by x and y coordinates
func get_tile_xy(x: int, y: int) -> Tile:
	var grid_position := Vector2i(x, y)
	return get_tile(grid_position)

# Function to get a tile by grid position
func get_tile(grid_position: Vector2i) -> Tile:
	var tile_index: int = grid_to_index(grid_position)
	if tile_index == -1:
		return null
	return tiles[tile_index]

# Function to get any blocking entity at a location
func get_blocking_entity_at_location(grid_position: Vector2i) -> Entity:
	# Check each entity to see if it blocks movement and is at the specified location
	for entity in entities:
		if entity.is_blocking_movement() and entity.grid_position == grid_position:
			return entity
	return null

# Function to convert grid position to grid index
func grid_to_index(grid_position: Vector2i) -> int:
	# Return -1 if the position is out of bounds
	if not is_in_bounds(grid_position):
		return -1
	return grid_position.y * width + grid_position.x

# Function to set up pathfinding
func setup_pathfinding() -> void:
	pathfinder = AStarGrid2D.new()
	pathfinder.region = Rect2i(0, 0, width, height)
	pathfinder.update()
	# Set up pathfinding for each tile
	for y in height:
		for x in width:
			var grid_position := Vector2i(x, y)
			var tile: Tile = get_tile(grid_position)
			pathfinder.set_point_solid(grid_position, not tile.is_walkable())
	# Register blocking entities for pathfinding
	for entity in entities:
		if entity.is_blocking_movement():
			register_blocking_entity(entity)

# Function to register a blocking entity
func register_blocking_entity(entity: Entity) -> void:
	pathfinder.set_point_weight_scale(entity.grid_position, entity_pathfinding_weight)

# Function to unregister a blocking entity
func unregister_blocking_entity(entity: Entity) -> void:
	pathfinder.set_point_weight_scale(entity.grid_position, 0)

# Function to get all actors that are in the map
func get_actors() -> Array[Entity]:
	var actors: Array[Entity] = []
	# Collect all entities that are actors and alive
	for entity in entities:
		if entity.get_entity_type() == Entity.EntityType.ACTOR and entity.is_alive():
			actors.append(entity)
	return actors

# Function to get all items that are in the map
func get_items() -> Array[Entity]:
	var items: Array[Entity] = []
	# Collect all entities that are items
	for entity in entities:
		if entity.consumable_component != null or entity.equippable_component != null:
			items.append(entity)
	return items

# Function to get an actor at a location
func get_actor_at_location(location: Vector2i) -> Entity:
	# Check each actor to see if it is at the specified location
	for actor in get_actors():
		if actor.grid_position == location:
			return actor
	return null

# Function to restore map data as MapData from save data dictionary
func restore(save_data: Dictionary) -> MapData:
	# Restore basic map properties
	coordinates = Vector3i(save_data["coordinates"]["x"], save_data["coordinates"]["y"], save_data["coordinates"]["z"])
	persistent = save_data["persistent"]
	width = save_data["width"]
	height = save_data["height"]
	down_stairs_location = Vector2i(save_data["down_stairs_location"]["x"], save_data["down_stairs_location"]["y"])
	# Set up tiles and restore their state
	_setup_tiles()
	for i in tiles.size():
		tiles[i].restore(save_data["tiles"][i])
	# Set up pathfinding
	setup_pathfinding()
	entities = [player]
	# Restore other entities
	for entity_data in save_data["entities"]:
		var new_entity := Entity.new(self, Vector2i.ZERO, "")
		new_entity.restore(entity_data)
		entities.append(new_entity)
		print("Restored entity: %s" % new_entity._definition.name)
	return self

# Function to get data of the map in the correct format to save it, along with all the entities in the map
func get_save_data() -> Dictionary:
	var save_data := {
		"coordinates": {"x": coordinates.x, "y": coordinates.y, "z": coordinates.z},
		"persistent": persistent,
		"width": width,
		"height": height,
		"down_stairs_location": {"x": down_stairs_location.x, "y": down_stairs_location.y},
		"entities": [],
		"tiles": []
	}
	# Save data for each entity except the player
	for entity in entities:
		if entity == player:
			continue
		save_data["entities"].append(entity.get_save_data())
	# Save data for each tile
	for tile in tiles:
		save_data["tiles"].append(tile.get_save_data())
	return save_data
