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
func generate(player: Entity) -> bool:
	# Generate the world map data
	map_data = world_generator.generate_world(player, Vector3i(0, 0, 0))
	entities.add_child(player)
	map_data_service.save_overworld(map_data)
	map_data_service.chunkify_map(map_data)
	# Connect the entity_placed signal to add entities to the map
	if not map_data.entity_placed.is_connected(entities.add_child):
		map_data.entity_placed.connect(entities.add_child)
	# Place entities and tiles on the map
	_place_entities()
	_place_tiles()
	# Emit the map_changed signal with the map dimensions
	SignalBus.map_changed.emit(map_data.width, map_data.height)
	return true

# Function to reload the overworld and switch the current map_data to the overworld.
func reload_overworld(player: Entity) -> void:
	# Load the overworld map
	map_data = map_data_service.load_overworld(player)
	# Connect the entity_placed signal to add entities to the map
	if not map_data.entity_placed.is_connected(entities.add_child):
		map_data.entity_placed.connect(entities.add_child)
	# Place entities and tiles on the map
	_place_entities()
	_place_tiles()
	SignalBus.clear_orphan_nodes.emit()

# Function to load a saved map and switch the current map_data to that saved map. 
func load_saved_map(player: Entity, coordinates: Vector3i):
	SignalBus.clear_orphan_nodes.emit()
	# Load the saved map data
	map_data = map_data_service.load_map(coordinates, player)
	# Connect the entity_placed signal to add entities to the map
	if not map_data.entity_placed.is_connected(entities.add_child):
		map_data.entity_placed.connect(entities.add_child)
	# Place entities and tiles on the map
	_place_entities()
	_place_tiles()
	SignalBus.clear_orphan_nodes.emit()

# Function called when a player explores a locale, which saves the current overworld map and goes through the process of generating a local
func explore_locale(overworld_tile: Tile) -> void:
	SignalBus.clear_orphan_nodes.emit()
	# Save the current overworld map
	map_data_service.save_overworld(map_data)
	# Save the player data
	get_parent().save_player()
	# Get the coordinates for the locale
	var locale_coordinates = Vector3i(overworld_tile.get_grid_position().x, overworld_tile.get_grid_position().y, 0)
	var player: Entity = map_data.player
	# Save the player's current state
	var player_save_data = player.get_save_data()
	var persistent = overworld_tile.world_tile_component.is_persistent()
	if map_data_service.current_chunk == overworld_tile.world_tile_component.chunk:
		if !map_data_service.check_saved_map(locale_coordinates):
			generate_chunk(player, overworld_tile.world_tile_component.chunk)
	elif !map_data_service.load_chunk(overworld_tile.world_tile_component.chunk):
		generate_chunk(player, overworld_tile.world_tile_component.chunk)
	# Clear the current map
	clear_map()
	# Load or generate the locale map
	load_saved_map(player, locale_coordinates)
	# Restore the player's state
	player.restore(player_save_data)
	player.grid_position = map_data.down_stairs_location
	player.position = Grid.grid_to_world(player.grid_position)
	player.map_data = map_data
	player.get_node("Camera2D").make_current()
	# Emit the map_changed signal with the map dimensions
	SignalBus.map_changed.emit(map_data.width, map_data.height)
	# Reset and update the field of view
	field_of_view.reset_fov()
	update_fov(player.grid_position)
	# Emit signals of the parent node
	get_parent().emit_signals()

# Function to generate a full chunk, called whenever a chunk is needed. 
func generate_chunk(player: Entity, chunk: int) -> void:
	SignalBus.clear_orphan_nodes.emit()
	if not map_data_service.map_chunks.has(chunk):
		print("Chunk %s not found" % chunk)
		return

	print("Generating chunk %s" % chunk)
	# Generate the chunk map data
	var chunk_tiles = map_data_service.map_chunks[chunk]

	for tile in chunk_tiles:
		if tile.world_tile_component.chunk == chunk:
			var coordinates = tile.get_grid_position()
			var locale_coordinates = Vector3i(coordinates.x, coordinates.y, 0)
			var locale_map = dungeon_generator.generate_dungeon(player, locale_coordinates, chunk)
			locale_map.persistent = tile.world_tile_component.is_persistent()
			if locale_map.persistent == true:
				map_data_service.save_map(locale_coordinates, locale_map)
			for entity in locale_map.entities:
				if entity != player:
					entity.queue_free()
			for locale_tile in locale_map.tiles:
				locale_tile.queue_free()
	
	print("Chunk %s generated" % chunk)
	map_data_service.save_chunk(chunk)

# Function to return to the overworld when a player leaves a locale map, saving the current map if needed and reloading the overworld
func return_to_overworld() -> void:
	SignalBus.clear_orphan_nodes.emit()
	# Save the current map if it is persistent
	if map_data.persistent == true:
		map_data_service.save_map(map_data.coordinates, map_data)
	else:
		print("Map is not persistent, not saving map")
	var player: Entity = map_data.player
	# Save the player's current state
	var player_save_data = player.get_save_data()
	var overworld_tile_location = Vector2i(map_data.coordinates.x, map_data.coordinates.y)
	# Clear the current map
	clear_map()
	# Load the overworld map
	reload_overworld(player)
	# Restore the player's state
	player.restore(player_save_data)
	player.grid_position = overworld_tile_location
	player.position = Grid.grid_to_world(player.grid_position)
	player.map_data = map_data
	player.get_node("Camera2D").make_current()
	# Emit the map_changed signal with the map dimensions
	SignalBus.map_changed.emit(map_data.width, map_data.height)
	# Reset and update the field of view
	field_of_view.reset_fov()
	update_fov(player.grid_position)
	# Emit signals to the parent node
	get_parent().emit_signals()
	# Save the overworld map
	map_data_service.save_overworld(map_data)
	# Save the player data
	get_parent().save_player()

# Function to clear the map of all entities and tiles, only called when transitioning to a different map
func clear_map() -> void:
	# Free all entities
	for entity in entities.get_children():
		if entity != map_data.player:
			entity.queue_free()
	# Free all tiles
	for tile in tiles.get_children():
		tile.queue_free()

# Function to load the game if the load game options was chosen, setting up the map and placing the player in the overworld. 
func load_game(player: Entity) -> bool:
	# Load all maps from file
	map_data_service._load_overworld_from_file()
	map_data_service.load_chunk(0)
	# Load the player data
	get_parent().load_player()
	# Load the overworld map
	map_data = map_data_service.load_overworld(player)
	player.map_data = map_data
	entities.add_child(player)
	# If no map data is found, create a new map
	if map_data == null:
		map_data = MapData.new(Vector3i(0, 0, 0), 0, 0, player, -1)
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
		if entity != map_data.player:
			entities.add_child(entity)
