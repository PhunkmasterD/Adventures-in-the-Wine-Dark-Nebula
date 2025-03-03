class_name MapData
extends RefCounted

signal entity_placed(entity)

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


func _init(world_coordinates: Vector3i, map_width: int, map_height: int, player: Entity, persistent_flag: bool = false) -> void:
	coordinates = world_coordinates
	persistent = persistent_flag
	width = map_width
	height = map_height
	self.player = player
	entities = []
	_setup_tiles()

func _setup_tiles() -> void:
	tiles = []
	for y in height:
		for x in width:
			var tile_position := Vector2i(x, y)
			var tile := Tile.new(player, tile_position, "water")
			tiles.append(tile)

func is_in_bounds(coordinate: Vector2i) -> bool:
	return (
		0 <= coordinate.x
		and coordinate.x < width
		and 0 <= coordinate.y
		and coordinate.y < height
	)


func get_tile_xy(x: int, y: int) -> Tile:
	var grid_position := Vector2i(x, y)
	return get_tile(grid_position)


func get_tile(grid_position: Vector2i) -> Tile:
	var tile_index: int = grid_to_index(grid_position)
	if tile_index == -1:
		return null
	return tiles[tile_index]


func get_blocking_entity_at_location(grid_position: Vector2i) -> Entity:
	for entity in entities:
		if entity.is_blocking_movement() and entity.grid_position == grid_position:
			return entity
	return null


func grid_to_index(grid_position: Vector2i) -> int:
	if not is_in_bounds(grid_position):
		return -1
	return grid_position.y * width + grid_position.x


func setup_pathfinding() -> void:
	pathfinder = AStarGrid2D.new()
	pathfinder.region = Rect2i(0, 0, width, height)
	pathfinder.update()
	for y in height:
		for x in width:
			var grid_position := Vector2i(x, y)
			var tile: Tile = get_tile(grid_position)
			pathfinder.set_point_solid(grid_position, not tile.is_walkable())
	for entity in entities:
		if entity.is_blocking_movement():
			register_blocking_entity(entity)


func register_blocking_entity(entity: Entity) -> void:
	pathfinder.set_point_weight_scale(entity.grid_position, entity_pathfinding_weight)


func unregister_blocking_entity(entity: Entity) -> void:
	pathfinder.set_point_weight_scale(entity.grid_position, 0)


func get_actors() -> Array[Entity]:
	var actors: Array[Entity] = []
	for entity in entities:
		if entity.get_entity_type() == Entity.EntityType.ACTOR and entity.is_alive():
			actors.append(entity)
	return actors


func get_items() -> Array[Entity]:
	var items: Array[Entity] = []
	for entity in entities:
		if entity.consumable_component != null or entity.equippable_component != null:
			items.append(entity)
	return items


func get_actor_at_location(location: Vector2i) -> Entity:
	for actor in get_actors():
		if actor.grid_position == location:
			return actor
	return null

func restore(save_data: Dictionary) -> MapData:
	coordinates = Vector3i(save_data["coordinates"]["x"], save_data["coordinates"]["y"], save_data["coordinates"]["z"])
	persistent = save_data["persistent"]
	width = save_data["width"]
	height = save_data["height"]
	down_stairs_location = Vector2i(save_data["down_stairs_location"]["x"], save_data["down_stairs_location"]["y"])
	_setup_tiles()
	for i in tiles.size():
		tiles[i].restore(save_data["tiles"][i])
	setup_pathfinding()
	player.restore(save_data["player"])
	player.map_data = self
	entities = [player]
	for entity_data in save_data["entities"]:
		var new_entity := Entity.new(self, Vector2i.ZERO, "")
		new_entity.restore(entity_data)
		entities.append(new_entity)
		print("Restored entity: %s" % new_entity._definition.name)
	return self

func get_save_data() -> Dictionary:
	var save_data := {
		"coordinates": {"x": coordinates.x, "y": coordinates.y, "z": coordinates.z},
		"persistent": persistent,
		"width": width,
		"height": height,
		"player": player.get_save_data(),
		"down_stairs_location": {"x": down_stairs_location.x, "y": down_stairs_location.y},
		"entities": [],
		"tiles": []
	}
	for entity in entities:
		if entity == player:
			continue
		save_data["entities"].append(entity.get_save_data())
	for tile in tiles:
		save_data["tiles"].append(tile.get_save_data())
	return save_data
