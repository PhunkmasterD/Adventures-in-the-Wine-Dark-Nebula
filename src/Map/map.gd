class_name Map
extends Node2D

# Signals for map changes
signal dungeon_floor_changed(floor)
signal map_changed

# Variables for map data and field of view radius
var map_data: MapData
@export var fov_radius: int = 16

# Onready variables for child nodes
@onready var tiles: Node2D = $Tiles
@onready var entities: Node2D = $Entities
@onready var world_generator: WorldGenerator = $WorldGenerator
@onready var dungeon_generator: DungeonGenerator = $DungeonGenerator
@onready var field_of_view: FieldOfView = $FieldOfView
@onready var map_data_service: MapDataService = $MapDataService

# Ready function to connect signals
func _ready() -> void:
	SignalBus.tile_explored.connect(explore_locale)
	SignalBus.return_to_overworld.connect(return_to_overworld)

# Function to generate the world map, called once at the beginning of the game
func generate(player: Entity) -> void:
	# Generate the world map data
	map_data = world_generator.generate_world(player, Vector3i(0, 0, 0))
	# Connect the entity_placed signal to add entities to the map
	if not map_data.entity_placed.is_connected(entities.add_child):
		map_data.entity_placed.connect(entities.add_child)
	# Place entities and tiles on the map
	_place_entities()
	_place_tiles()
	# Emit the map_changed signal with the map dimensions
	SignalBus.map_changed.emit(map_data.width, map_data.height)

# Function to generate a local map, called whenever a local map is needed. Currently only generates dungeons. 
func generate_locale(player: Entity, location: Vector3i, persistent_flag: bool = false) -> void:
	# Generate dungeon map data
	var locale_coordinates = Vector3i(location.x, location.y, 0)
	map_data = dungeon_generator.generate_dungeon(player, locale_coordinates)
	# Set the map's persistence flag
	map_data.persistent = persistent_flag
	# Save the map if it is persistent
	if map_data.persistent == true:
		map_data_service.save_map(locale_coordinates, map_data)
	# Connect the entity_placed signal to add entities to the map
	if not map_data.entity_placed.is_connected(entities.add_child):
		map_data.entity_placed.connect(entities.add_child)
	# Place entities and tiles on the map
	_place_entities()
	_place_tiles()

# Function to load a saved map and switch the current map_data to that saved map. 
func load_saved_map(player: Entity, coordinates: Vector3i):
	# Load the saved map data
	map_data = map_data_service.load_map(coordinates, player)
	# Connect the entity_placed signal to add entities to the map
	if not map_data.entity_placed.is_connected(entities.add_child):
		map_data.entity_placed.connect(entities.add_child)
	# Place entities and tiles on the map
	_place_entities()
	_place_tiles()

# Function called when a player explores a locale, which saves the current overworld map and goes through the process of generating a local
func explore_locale(overworld_tile: Tile) -> void:
	# Save the current overworld map
	map_data_service.save_map(map_data.coordinates, map_data)
	# Get the coordinates for the locale
	var locale_coordinates = Vector3i(overworld_tile.get_grid_position().x, overworld_tile.get_grid_position().y, 0)
	var player: Entity = map_data.player
	# Save the player's current state
	var player_save_data = player.get_save_data()
	var persistent = overworld_tile.is_persistent()
	# Remove the player from the current map
	entities.remove_child(player)
	# Clear the current map
	clear_map()
	# Load or generate the locale map
	if map_data_service.check_saved_map(locale_coordinates):
		load_saved_map(player, locale_coordinates)
	else:
		generate_locale(player, locale_coordinates, persistent)
	# Restore the player's state
	player.restore(player_save_data)
	player.grid_position = map_data.down_stairs_location
	player.position = Grid.grid_to_world(player.grid_position)
	player.get_node("Camera2D").make_current()
	# Emit the map_changed signal with the map dimensions
	SignalBus.map_changed.emit(map_data.width, map_data.height)
	# Reset and update the field of view
	field_of_view.reset_fov()
	update_fov(player.grid_position)
	# Emit signals of the parent node
	get_parent().emit_signals()

# Function to return to the overworld when a player leaves a locale map, saving the current map if needed and reloading the overworld
func return_to_overworld() -> void:
	# Save the current map if it is persistent
	if map_data.persistent == true:
		map_data_service.save_map(map_data.coordinates, map_data)
	else:
		print("Map is not persistent, not saving map")
	var player: Entity = map_data.player
	# Save the player's current state
	var player_save_data = player.get_save_data()
	var overworld_tile_location = Vector2i(map_data.coordinates.x, map_data.coordinates.y)
	# Remove the player from the current map
	entities.remove_child(player)
	# Clear the current map
	clear_map()
	# Load the overworld map
	load_saved_map(player, Vector3i(0, 0, 0))
	# Restore the player's state
	player.restore(player_save_data)
	player.grid_position = overworld_tile_location
	player.position = Grid.grid_to_world(player.grid_position)
	player.get_node("Camera2D").make_current()
	# Emit the map_changed signal with the map dimensions
	SignalBus.map_changed.emit(map_data.width, map_data.height)
	# Reset and update the field of view
	field_of_view.reset_fov()
	update_fov(player.grid_position)
	# Emit signals to the parent node
	get_parent().emit_signals()
	# Save the overworld map
	map_data_service.save_map(map_data.coordinates, map_data)

# Function to clear the map of all entities and tiles, only called when transitioning to a different map
func clear_map() -> void:
	# Free all entities
	for entity in entities.get_children():
		entity.queue_free()
	# Free all tiles
	for tile in tiles.get_children():
		tile.queue_free()

# Function to save all maps, currently not used. 
func save_maps() -> bool:
	# Save all maps to file
	map_data_service._save_to_file()
	return true

# Function to load the game if the load game options was chosen, setting up the map and placing the player in the overworld. 
func load_game(player: Entity) -> bool:
	# Load all maps from file
	map_data_service._load_from_file()
	# Load the overworld map
	map_data = map_data_service.load_map(Vector3i(0, 0, 0), player)
	# If no map data is found, create a new map
	if map_data == null:
		map_data = MapData.new(Vector3i(0, 0, 0), 0, 0, player)
		map_data.entity_placed.connect(entities.add_child)
	# Place tiles and entities on the map
	_place_tiles()
	_place_entities()
	return true

# Function to update the field of view of the player, drawing the map accordingly.
func update_fov(player_position: Vector2i) -> void:
	# Update the field of view based on the player's position
	field_of_view.update_fov(map_data, player_position, fov_radius)
	# Update the visibility of entities based on the field of view
	for entity in map_data.entities:
		entity.visible = map_data.get_tile(entity.grid_position).is_in_view

# Function to draw all tiles on the map
func _place_tiles() -> void:
	# Add each tile to the tiles node
	for tile in map_data.tiles:
		tiles.add_child(tile)

# Function to draw all entities on the map
func _place_entities() -> void:
	# Add each entity to the entities node
	for entity in map_data.entities:
		entities.add_child(entity)
