class_name WorldGenerator
extends Node

const tile_types = {
	"meadow": 50,
	"forest": 30,
}

var map_width: int = MapConfig.world_map_width
var map_height: int = MapConfig.world_map_height

var num_biomes: int = MapConfig.num_biomes

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()


func generate_world(player: Entity, coordinates: Vector3i) -> MapData:
	print("Generating world...")
	var world := MapData.new(coordinates, map_width, map_height, player)
	var map:= Rect2i(0, 0, map_width, map_height)
	world.entities.append(player)

	print("Generating biomes...")	
	var biomes = _generate_biomes()
	for biome in biomes:
		print("Placing %s biome at %s" % [biome["type"], biome["position"]])
		var biome_type = biome["type"]
		var biome_position = biome["position"]
		var biome_size = biome["size"]

		for y in range(biome_position.y - biome_size, biome_position.y + biome_size):
			for x in range(biome_position.x - biome_size, biome_position.x + biome_size):
				if x >= 0 and x < map_width and y >= 0 and y < map_height:
					var tile_position = Vector2i(x, y)
					var tile: Tile = world.get_tile(tile_position)
					tile.set_tile_type(biome_type)

	print("Biomes placed, finalizing world...")
	player.grid_position = map.get_center()
	player.map_data = world
	 
	world.setup_pathfinding()
	print("World generation complete")
	return world

func _generate_biomes() -> Array:
	var biomes = []
	
	for i in range(num_biomes):
		var biome = {
			"type": _pick_weighted(tile_types),
			"position": Vector2i(_rng.randi_range(0, map_width - 1), _rng.randi_range(0, map_height - 1)),
			"size": _rng.randi_range(5, 15)
		}
		biomes.append(biome)
	return biomes


func _pick_weighted(weighted_chances: Dictionary) -> String:
	var keys: Array[String] = []
	var cumulative_chances := []
	var sum: int = 0
	for key in weighted_chances:
		keys.append(key)
		var chance: int = weighted_chances[key]
		sum += chance
		cumulative_chances.append(sum)
	var random_chance: int = _rng.randi_range(0, sum - 1)
	var selection: String
	
	for i in cumulative_chances.size():
		if cumulative_chances[i] > random_chance:
			selection = keys[i]
			break
	
	return selection
