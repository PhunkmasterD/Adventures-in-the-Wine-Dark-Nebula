class_name MapDataService
extends Node

# Define the size of each chunk
const CHUNK_SIZE = 3

# Variables for overworld dimensions
var overworld_width: int = MapConfig.world_map_width
var overworld_height: int = MapConfig.world_map_height
var overworld_depth: int = MapConfig.world_map_depth

# Dictionary to store maps
var overworld_map: Dictionary
var maps: Dictionary = {}
var current_chunk: int = 0
var map_chunks: Dictionary = {}

func _init() -> void:
	SignalBus.clear_orphan_nodes.connect(_on_clear_orphan_nodes)

func _on_clear_orphan_nodes():
	if self.get_parent() == null:
		queue_free()

# Function to convert coordinates to index
func coordinate_to_index(coordinate: Vector3i) -> int:
	return coordinate.x + coordinate.y * overworld_width + coordinate.z * overworld_width * overworld_height

# Function to convert index to coordinates
func index_to_coordinates(index: int) -> Vector3i:
	var x = index % overworld_width
	var y = (index / overworld_width) % overworld_height
	var z = index / (overworld_width * overworld_height)
	return Vector3i(x, y, z)

# Function to chunkify a map
func chunkify_map(map_data: MapData):
	map_chunks.clear()
	# Iterate through each tile in the map
	for tile in map_data.tiles:
		var tile_coordinates = tile.get_grid_position()
		# Calculate the chunk coordinates for each tile based on its position
		var chunk_x = int(tile_coordinates.x / CHUNK_SIZE)
		var chunk_y = int(tile_coordinates.y / CHUNK_SIZE)
		var chunk_coordinates = Vector3i(chunk_x, chunk_y, 0)
		var chunk_index = coordinate_to_index(chunk_coordinates)
		if tile.world_tile_component:
			tile.world_tile_component.chunk = chunk_index
		# Add the tile to the corresponding chunk in the map_chunks dictionary
		if not map_chunks.has(chunk_index):
			map_chunks[chunk_index] = []
		
		map_chunks[chunk_index].append(tile)
	print("Generated %s chunks" % map_chunks.size())

# Function to load a chunk
func load_chunk(chunk: int):
	print("Loading chunk %s" % chunk)
	if current_chunk != chunk:
		save_chunk(current_chunk)
	maps.clear()
	current_chunk = chunk
	var chunk_exists: bool = FileAccess.file_exists("user://save_data/map_data_%s.dat" % chunk)
	if chunk_exists:
		_load_from_file(chunk)
		return true
	return false

func save_chunk(chunk: int) -> bool:
	_save_to_file("map_data_%s" % chunk, maps)
	print("Saving chunk %s" % chunk)
	return true

# Function to check if a map is saved in the given chunk
func check_saved_map(map_coordinates: Vector3i) -> bool:
	var index = coordinate_to_index(map_coordinates)
	print("Checking for saved map at coordinates %s, index %s" % [map_coordinates, index])
	if index in maps:
		return true
	print("Map not found")
	return false

# Function to save a map to file
func save_map(map_coordinates: Vector3i, map_data: MapData):
	var index = coordinate_to_index(map_coordinates)
	# Save the map data in the dictionary
	maps[index] = map_data.get_save_data()

# Function to load a map from the current map dictionary
func load_map(map_coordinates: Vector3i, player: Entity) -> MapData:
	var index = coordinate_to_index(map_coordinates)
	print("Loading map at index %s" % index)
	if index in maps:
		print("Map found at index: %s" % index)
		# Create a new MapData instance and restore its state from the saved data
		var map_data = MapData.new(map_coordinates, overworld_width, overworld_height, player, 0)
		map_data = map_data.restore(maps[index])
		return map_data
	print("Map not found at index: %s" % index)
	return null

# Function to save all of the map data to file
func _save_to_file(file_name: String, data: Dictionary) -> void:
	# Open the file for writing
	var file = FileAccess.open("user://save_data/%s.dat" % file_name, FileAccess.WRITE)
	# Convert the maps dictionary to a JSON string
	var save_string: String = JSON.stringify(data)
	# Calculate the hash of the save string
	var save_hash: String = save_string.sha256_text()
	# Store the hash and the save string in the file
	file.store_line(save_hash)
	file.store_line(save_string)

# Function to load map data from a file
func _load_from_file(chunk: int) -> void:
	print("Loading map data from file...")
	# Open the file for reading
	var file = FileAccess.open("user://save_data/map_data_%s.dat" % chunk, FileAccess.READ)
	# Retrieve the hash and the save string from the file
	var retrieved_hash: String = file.get_line()
	var save_string: String = file.get_line()
	# Calculate the hash of the save string
	var calculated_hash: String = save_string.sha256_text()
	# Check if the retrieved hash matches the calculated hash
	var valid_hash: bool = retrieved_hash == calculated_hash
	if not valid_hash:
		print("Invalid hash, map data corrupted")
		return
	# Parse the save string to a dictionary
	var loaded_maps = JSON.parse_string(save_string)
	if typeof(loaded_maps) == TYPE_DICTIONARY:
		maps.clear()
		# Restore the maps dictionary from the loaded data
		for key in loaded_maps.keys():
			maps[int(key)] = loaded_maps[key]
	print("Map data loaded from file")
	print("Number of maps: %s" % maps.size())

# Function to save the overworld map to file
func save_overworld(map_data: MapData):
	print("Saving overworld map data...")
	overworld_map = map_data.get_save_data()
	_save_to_file("overworld_map_data", overworld_map)

func load_overworld(player: Entity):
	print("Loading overworld map data...")
	var map_data = MapData.new(Vector3i(0, 0, 0), overworld_width, overworld_height, player, -1)
	map_data = map_data.restore(overworld_map)
	chunkify_map(map_data)
	return map_data

# Function to load the overworld map from file
func _load_overworld_from_file() -> void:
	print("Loading overworld map from file...")
	# Open the file for reading
	var file = FileAccess.open("user://save_data/overworld_map_data.dat", FileAccess.READ)
	# Retrieve the hash and the save string from the file
	var retrieved_hash: String = file.get_line()
	var save_string: String = file.get_line()
	# Calculate the hash of the save string
	var calculated_hash: String = save_string.sha256_text()
	# Check if the retrieved hash matches the calculated hash
	var valid_hash: bool = retrieved_hash == calculated_hash
	if not valid_hash:
		print("Invalid hash, overworld map data corrupted")
		return
	# Parse the save string to a dictionary
	overworld_map = JSON.parse_string(save_string)
	print("Overworld map data loaded from file")
