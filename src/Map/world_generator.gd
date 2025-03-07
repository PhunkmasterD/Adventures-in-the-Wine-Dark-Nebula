class_name WorldGenerator
extends Node

# Map dimensions and number of biomes from configuration
var map_width: int = MapConfig.world_map_width
var map_height: int = MapConfig.world_map_height
var num_biomes: int = MapConfig.num_biomes

# Random number generator instance
var _rng := RandomNumberGenerator.new()

# Randomize the RNG seed when the node is ready
func _ready() -> void:
	_rng.randomize()

# Generate the world map with biomes and place the player entity
func generate_world(player: Entity, coordinates: Vector3i) -> MapData:
	print("Generating world...")
	var world := MapData.new(coordinates, map_width, map_height, player, -1)
	var map:= Rect2i(0, 0, map_width, map_height)
	world.entities.append(player)

	for tile in world.tiles:
		tile.set_tile_type(TileTypes.TileKey.WATER)

	print("Generating islands...")	
	var biomes = _generate_biomes()
	for biome in biomes:
		print("Placing %s island at %s" % [biome["type"], biome["position"]])
		var biome_type = biome["type"]
		var biome_position = biome["position"]
		var biome_size = biome["size"]

		# Place the island tiles within the map boundaries
		for y in range(biome_position.y, biome_position.y + biome_size):
			for x in range(biome_position.x, biome_position.x + biome_size):
				if x >= 0 and x < map_width and y >= 0 and y < map_height:
					var tile_position = Vector2i(x, y)
					var tile: Tile = world.get_tile(tile_position)
					tile.set_tile_type(biome_type)

	print("Islands placed, finalizing world...")
	player.grid_position = Vector2i(0, 0)
	player.map_data = world
		
	world.setup_pathfinding()
	print("World generation complete")
	return world

# Generate a list of islands with random positions and sizes
func _generate_biomes() -> Array:
	var tile_type_weights = {
		TileTypes.TileKey.MEADOW: 50,
		TileTypes.TileKey.FOREST: 30,
	}
	var biomes = []

	for i in range(num_biomes):
		# Create an island with a random type, position, and size
		var island_size = _rng.randi_range(3, 5)
		var biome = {
			"type": _pick_weighted(tile_type_weights),
			"position": Vector2i(_rng.randi_range(0, map_width - island_size), _rng.randi_range(0, map_height - island_size)),
			"size": island_size
		}
		biomes.append(biome)
	return biomes

# Pick a tile type based on weighted chances
func _pick_weighted(weighted_chances: Dictionary) -> TileTypes.TileKey:
	var keys: Array[TileTypes.TileKey] = []
	var cumulative_chances := []
	var sum: int = 0
	
	# Calculate cumulative chances
	for key in weighted_chances:
		keys.append(key)
		var chance: int = weighted_chances[key]
		sum += chance
		cumulative_chances.append(sum)
	
	# Pick a random chance
	var random_chance: int = _rng.randi_range(0, sum - 1)
	var selection: TileTypes.TileKey
	
	# Select the tile type based on the random chance
	for i in cumulative_chances.size():
		if cumulative_chances[i] > random_chance:
			selection = keys[i]
			break
	
	return selection
