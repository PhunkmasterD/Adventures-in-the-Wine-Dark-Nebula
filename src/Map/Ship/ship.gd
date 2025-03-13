class_name Ship
extends Node

var ship_name: String
var ship_map: MapData
var player: Entity
var starting_position: Vector2i

# Initialization function
func generate_ship(player_data: Entity) -> void:
	player = player_data
	print("Generating ship...")
	var ship := MapData.new(Vector3i(0, 0, 0), 20, 20, player, -1)
	ship.entities.append(player)

	var welcome_sign := Entity.new(ship, Vector2i(5, 5), "signpost")
	ship.entities.append(welcome_sign)
	var teleporter := Entity.new(ship, Vector2i(5, 6), "teleporter")
	ship.entities.append(teleporter)

	var ship_room := Rect2i(0, 0, 7, 13)

	var inner: Rect2i = ship_room.grow(-1)
	for y in range(inner.position.y, inner.end.y + 1):
		for x in range(inner.position.x, inner.end.x + 1):
			_carve_tile(ship, x, y)

	starting_position = ship_room.get_center()
	
	ship.setup_pathfinding()
	print("World generation complete")
	ship_map = ship
	
# Function to carve a single tile in the dungeon
func _carve_tile(dungeon: MapData, x: int, y: int) -> void:
	var tile_position = Vector2i(x, y)
	var tile: Tile = dungeon.get_tile(tile_position)
	tile.set_tile_type(TileTypes.TileKey.FLOOR)