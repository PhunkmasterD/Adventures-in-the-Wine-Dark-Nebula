class_name DungeonGenerator
extends Node

# Constants for item and monster generation
const max_items_by_floor = [
	[1, 1],
	[4, 2]
]

const max_monsters_by_floor = [
	[1, 2],
	[4, 3],
	[6, 5]
]

const item_chances = {
	0: {"health_potion": 35},
	2: {"confusion_scroll": 10},
	4: {"lightning_scroll": 25},
	6: {"fireball_scroll": 25},
}

const enemy_chances = {
	0: {"orc": 80},
	3: {"troll": 15},
	5: {"troll": 30},
	7: {"troll": 60}
}

# Variables for dungeon generation settings
var map_width: int = MapConfig.dungeon_map_width
var map_height: int = MapConfig.dungeon_map_height

var max_rooms: int = MapConfig.dungeon_max_rooms
var room_max_size: int = MapConfig.dungeon_room_max_size
var room_min_size: int = MapConfig.dungeon_room_min_size

var _rng := RandomNumberGenerator.new()

# Ready function to randomize the RNG
func _ready() -> void:
	_rng.randomize()

# Main function to generate a dungeon
func generate_dungeon(player: Entity, coordinates: Vector3i) -> MapData:
	var dungeon := MapData.new(coordinates, map_width, map_height, player)
	dungeon.entities.append(player)

	var rooms: Array[Rect2i] = []
	var center_last_room: Vector2i
	
	# Try to generate the specified number of rooms
	for _try_room in max_rooms:
		# Randomly determine the size of the room
		var room_width: int = _rng.randi_range(room_min_size, room_max_size)
		var room_height: int = _rng.randi_range(room_min_size, room_max_size)
		
		# Randomly determine the position of the room
		var x: int = _rng.randi_range(0, dungeon.width - room_width - 1)
		var y: int = _rng.randi_range(0, dungeon.height - room_height - 1)
		
		var new_room := Rect2i(x, y, room_width, room_height)
	
		# Check for intersections with existing rooms
		var has_intersections := false
		for room in rooms:
			if room.intersects(new_room):
				has_intersections = true
				break
		if has_intersections:
			continue
		
		# Carve out the new room
		_carve_room(dungeon, new_room)
		center_last_room = new_room.get_center()
		
		# Set the player's starting position in the first room
		if rooms.is_empty():
			player.grid_position = new_room.get_center()
			player.map_data = dungeon
		else:
			# Create a tunnel between the new room and the previous room
			_tunnel_between(dungeon, rooms.back().get_center(), new_room.get_center())
		
		# Place entities in the new room
		_place_entities(dungeon, new_room, 1)
		
		rooms.append(new_room)
	
	# Set the location of the down stairs
	dungeon.down_stairs_location = center_last_room
	var down_tile: Tile = dungeon.get_tile(center_last_room)
	down_tile.set_tile_type(TileTypes.TileKey.DOWN_STAIRS)
	
	# Set up pathfinding for the dungeon
	dungeon.setup_pathfinding()
	return dungeon

# Function to square carve a room in the dungeon
func _carve_room(dungeon: MapData, room: Rect2i) -> void:
	var inner: Rect2i = room.grow(-1)
	# Carve out each tile within the room
	for y in range(inner.position.y, inner.end.y + 1):
		for x in range(inner.position.x, inner.end.x + 1):
			_carve_tile(dungeon, x, y)

# Function to create a horizontal tunnel
func _tunnel_horizontal(dungeon: MapData, y: int, x_start: int, x_end: int) -> void:
	var x_min: int = mini(x_start, x_end)
	var x_max: int = maxi(x_start, x_end)
	# Carve out each tile within the horizontal tunnel
	for x in range(x_min, x_max + 1):
		_carve_tile(dungeon, x, y)

# Function to create a vertical tunnel
func _tunnel_vertical(dungeon: MapData, x: int, y_start: int, y_end: int) -> void:
	var y_min: int = mini(y_start, y_end)
	var y_max: int = maxi(y_start, y_end)
	# Carve out each tile within the vertical tunnel
	for y in range(y_min, y_max + 1):
		_carve_tile(dungeon, x, y)

# Function to create a tunnel between two points, with a curve if needed
func _tunnel_between(dungeon: MapData, start: Vector2i, end: Vector2i) -> void:
	# Randomly decide whether to carve horizontally first or vertically first
	if _rng.randf() < 0.5:
		_tunnel_horizontal(dungeon, start.y, start.x, end.x)
		_tunnel_vertical(dungeon, end.x, start.y, end.y)
	else:
		_tunnel_vertical(dungeon, start.x, start.y, end.y)
		_tunnel_horizontal(dungeon, end.y, start.x, end.x)

# Function to carve a single tile in the dungeon
func _carve_tile(dungeon: MapData, x: int, y: int) -> void:
	var tile_position = Vector2i(x, y)
	var tile: Tile = dungeon.get_tile(tile_position)
	tile.set_tile_type(TileTypes.TileKey.FLOOR)

# Function to get the maximum value of an entity type for a floor
func _get_max_value_for_floor(weighted_chances_by_floor: Array, current_floor: int) -> int:
	var current_value = 0
	
	# Iterate through the chances and get the maximum value for the current floor
	for chance in weighted_chances_by_floor:
		if chance[0] > current_floor:
			break
		else:
			current_value = chance[1]
	
	return current_value

# Function to get entities at random
func _get_entities_at_random(weighted_chances_by_floor: Dictionary, number_of_entities: int, current_floor: int) -> Array[String]:
	var entity_weighted_chances = {}
	var chosen_entities: Array[String] = []
	
	# Collect the weighted chances for the current floor
	for key in weighted_chances_by_floor:
		if key > current_floor:
			break
		else:
			for entity_name in weighted_chances_by_floor[key]:
				entity_weighted_chances[entity_name] = weighted_chances_by_floor[key][entity_name]
	
	# Pick entities based on the weighted chances
	for _i in number_of_entities:
		chosen_entities.append(_pick_weighted(entity_weighted_chances))
	
	return chosen_entities

# Function to pick a weighted entity
func _pick_weighted(weighted_chances: Dictionary) -> String:
	var keys: Array[String] = []
	var cumulative_chances := []
	var sum: int = 0
	# Calculate the cumulative chances
	for key in weighted_chances:
		keys.append(key)
		var chance: int = weighted_chances[key]
		sum += chance
		cumulative_chances.append(sum)
	# Pick a random entity based on the cumulative chances
	var random_chance: int = _rng.randi_range(0, sum - 1)
	var selection: String
	
	for i in cumulative_chances.size():
		if cumulative_chances[i] > random_chance:
			selection = keys[i]
			break
	
	return selection

# Function to place entities in a room
func _place_entities(dungeon: MapData, room: Rect2i, current_floor: int) -> void:
	# Get the maximum number of monsters and items for the current floor
	var max_monsters_per_room: int = _get_max_value_for_floor(max_monsters_by_floor, current_floor)
	var max_items_per_room: int = _get_max_value_for_floor(max_items_by_floor, current_floor)
	# Randomly determine the number of monsters and items to place
	var number_of_monsters: int = _rng.randi_range(0, max_monsters_per_room)
	var number_of_items: int = _rng.randi_range(0, max_items_per_room)
	
	# Get the list of monsters and items to place
	var monsters: Array[String] = _get_entities_at_random(enemy_chances, number_of_monsters, current_floor)
	var items: Array[String] = _get_entities_at_random(item_chances, number_of_items, current_floor)
	
	var entity_keys: Array[String] = monsters + items
	
	# Place each entity in the room
	for entity_key in entity_keys:
		var x: int = _rng.randi_range(room.position.x + 1, room.end.x - 1)
		var y: int = _rng.randi_range(room.position.y + 1, room.end.y - 1)
		var new_entity_position := Vector2i(x, y)
		
		# Check if the position is already occupied
		var can_place = true
		for entity in dungeon.entities:
			if entity.grid_position == new_entity_position:
				can_place = false
				break
		
		# Place the entity if the position is not occupied
		if can_place:
			var new_entity := Entity.new(dungeon, new_entity_position, entity_key)
			dungeon.entities.append(new_entity)
