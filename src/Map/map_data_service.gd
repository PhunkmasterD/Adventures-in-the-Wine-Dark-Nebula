class_name MapDataService
extends Node

# Define the size of each chunk
const CHUNK_SIZE = 9

# Variables for overworld dimensions
var overworld_width: int = MapConfig.world_map_width
var overworld_height: int = MapConfig.world_map_height
var overworld_depth: int = MapConfig.world_map_depth

# Dictionary to store maps
var overworld_map: Dictionary
var maps: Dictionary = {}
var map_chunks: Dictionary = {}

# Function to convert coordinates to index
func coordinate_to_index(coordinate: Vector3i) -> int:
	return coordinate.x + coordinate.y * overworld_width + coordinate.z * overworld_width * overworld_height

# Function to convert index to coordinates
func index_to_coordinates(index: int) -> Vector3i:
	var x = index % overworld_width
	var y = (index / overworld_width) % overworld_height
	var z = index / (overworld_width * overworld_height)
	return Vector3i(x, y, z)

# Function to check if a map is saved
func check_saved_map(map_coordinates: Vector3i) -> bool:
	print("Checking for saved map...")
	var index = coordinate_to_index(map_coordinates)
	print("Checking for saved map at coordinates %s, index %s" % [map_coordinates, index])
	if index in maps:
		print("Map found")
		return true
	print("Map not found")
	return false

# Function to save the overworld map to file
func save_overworld(map_data: MapData):
	print("Saving overworld map data...")
	overworld_map = map_data.get_save_data()
	_save_to_file("overworld_map_data", overworld_map)

func load_overworld(player: Entity):
	print("Loading overworld map data...")
	var map_data = MapData.new(Vector3i(0, 0, 0), overworld_width, overworld_height, player)
	map_data = map_data.restore(overworld_map)
	return map_data

# Function to save a map to file
func save_map(map_coordinates: Vector3i, map_data: MapData):
	print("Saving map data...")
	var index = coordinate_to_index(map_coordinates)
	print("Saving map at coordinates: %s, index: %s" % [map_coordinates, index])
	# Save the map data in the dictionary
	maps[index] = map_data.get_save_data()
	# Save the dictionary to file
	_save_to_file("map_data", maps)

# Function to load a map from the current map dictionary
func load_map(map_coordinates: Vector3i, player: Entity) -> MapData:
	print("Loading map data...")
	var index = coordinate_to_index(map_coordinates)
	print("Loading map at index %s" % index)
	if index in maps:
		print("Map found at index: %s" % index)
		# Create a new MapData instance and restore its state from the saved data
		var map_data = MapData.new(map_coordinates, overworld_width, overworld_height, player)
		map_data = map_data.restore(maps[index])
		print("Map restored at index: %s" % index)
		return map_data
	print("Map not found at index: %s" % index)
	return null

# Function to save all of the map data to file
func _save_to_file(file_name: String, data: Dictionary) -> void:
	print("Saving map data to file...")
	# Open the file for writing
	var file = FileAccess.open("user://%s.dat" % file_name, FileAccess.WRITE)
	# Convert the maps dictionary to a JSON string
	var save_string: String = JSON.stringify(data)
	# Calculate the hash of the save string
	var save_hash: String = save_string.sha256_text()
	# Store the hash and the save string in the file
	file.store_line(save_hash)
	file.store_line(save_string)
	print("Map data saved to file")


# Function to load the overworld map from file
func _load_overworld_from_file() -> void:
	print("Loading overworld map from file...")
	print("Retrieiving overworld map data...")
	# Open the file for reading
	var file = FileAccess.open("user://overworld_map_data.dat", FileAccess.READ)
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

# Function to load map data from file
func _load_from_file() -> void:
	print("Loading map data from file...")
	print("Retrieving Map Data")
	# Open the file for reading
	var file = FileAccess.open("user://map_data.dat", FileAccess.READ)
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
