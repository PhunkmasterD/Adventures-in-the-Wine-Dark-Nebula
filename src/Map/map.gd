class_name Map
extends Node2D

signal dungeon_floor_changed(floor)
signal map_changed

var map_data: MapData
@export var fov_radius: int = 16

@onready var tiles: Node2D = $Tiles
@onready var entities: Node2D = $Entities
@onready var world_generator: WorldGenerator = $WorldGenerator
@onready var dungeon_generator: DungeonGenerator = $DungeonGenerator
@onready var field_of_view: FieldOfView = $FieldOfView
@onready var map_data_service: MapDataService = $MapDataService

func _ready() -> void:
	#SignalBus.player_descended.connect(next_floor)
	SignalBus.tile_explored.connect(explore_locale)
	SignalBus.return_to_overworld.connect(return_to_overworld)

func generate(player: Entity) -> void:
	map_data = world_generator.generate_world(player, Vector3i(0, 0, 0))
	if not map_data.entity_placed.is_connected(entities.add_child):
		map_data.entity_placed.connect(entities.add_child)
	_place_entities()
	_place_tiles()
	SignalBus.map_changed.emit(map_data.width, map_data.height)

func generate_locale(player: Entity, location: Vector3i, persistent_flag: bool = false) -> void:
	var locale_coordinates = Vector3i(location.x, location.y, 0)
	map_data = dungeon_generator.generate_dungeon(player, locale_coordinates)
	map_data.persistent = persistent_flag
	if map_data.persistent == true:
		map_data_service.save_map(locale_coordinates, map_data)
	if not map_data.entity_placed.is_connected(entities.add_child):
		map_data.entity_placed.connect(entities.add_child)
	_place_entities()
	_place_tiles()

func load_saved_map(player: Entity, coordinates: Vector3i):
	map_data = map_data_service.load_map(coordinates, player)
	if not map_data.entity_placed.is_connected(entities.add_child):
		map_data.entity_placed.connect(entities.add_child)
	_place_entities()
	_place_tiles()


func explore_locale(overworld_tile: Tile) -> void:
	map_data_service.save_map(map_data.coordinates, map_data)
	var locale_coordinates = Vector3i(overworld_tile.get_grid_position().x, overworld_tile.get_grid_position().y, 0)
	var player: Entity = map_data.player
	var player_save_data = player.get_save_data()
	var persistent = overworld_tile.is_persistent()
	entities.remove_child(player)
	clear_map()
	if map_data_service.check_saved_map(locale_coordinates):
		load_saved_map(player, locale_coordinates)
	else:
		generate_locale(player, locale_coordinates, persistent)
	player.restore(player_save_data)
	player.grid_position = map_data.down_stairs_location
	player.position = Grid.grid_to_world(player.grid_position)
	player.get_node("Camera2D").make_current()
	SignalBus.map_changed.emit(map_data.width, map_data.height)
	field_of_view.reset_fov()
	update_fov(player.grid_position)
	get_parent().emit_signals()

func return_to_overworld() -> void:
	if map_data.persistent == true:
		map_data_service.save_map(map_data.coordinates, map_data)
	else:
		print("Map is not persistent, not saving map")
	var player: Entity = map_data.player
	var player_save_data = player.get_save_data()
	var overworld_tile_location = Vector2i(map_data.coordinates.x, map_data.coordinates.y)
	entities.remove_child(player)
	clear_map()
	load_saved_map(player, Vector3i(0, 0, 0))
	player.restore(player_save_data)
	player.grid_position = overworld_tile_location
	player.position = Grid.grid_to_world(player.grid_position)
	player.get_node("Camera2D").make_current()
	SignalBus.map_changed.emit(map_data.width, map_data.height)
	field_of_view.reset_fov()
	update_fov(player.grid_position)
	get_parent().emit_signals()
	map_data_service.save_map(map_data.coordinates, map_data)

func clear_map() -> void:
	for entity in entities.get_children():
		entity.queue_free()
	for tile in tiles.get_children():
		tile.queue_free()

func save_maps() -> bool:
	map_data_service.save_placer(map_data.player)
	map_data_service._save_to_file()
	return true

func load_game(player: Entity) -> bool:
	map_data_service._load_from_file()
	map_data = map_data_service.load_map(Vector3i(0, 0, 0), player)
	if map_data == null:
		map_data = MapData.new(Vector3i(0, 0, 0), 0, 0, player)
		map_data.entity_placed.connect(entities.add_child)
	_place_tiles()
	_place_entities()
	return true

func update_fov(player_position: Vector2i) -> void:
	field_of_view.update_fov(map_data, player_position, fov_radius)

	for entity in map_data.entities:
		entity.visible = map_data.get_tile(entity.grid_position).is_in_view

func _place_tiles() -> void:
	for tile in map_data.tiles:
		tiles.add_child(tile)

func _place_entities() -> void:
	for entity in map_data.entities:
		entities.add_child(entity)
