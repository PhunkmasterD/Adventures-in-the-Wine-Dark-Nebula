class_name Tile
extends Sprite2D

const tile_types = {
    "meadow": preload("res://assets/definitions/tiles/overworld/tile_definition_meadow.tres"),
    "forest": preload("res://assets/definitions/tiles/overworld/tile_definition_forest.tres"),
    "down_stairs": preload("res://assets/definitions/tiles/map_tiles/tile_definition_down_stairs.tres"),
    "water": preload("res://assets/definitions/tiles/map_tiles/tile_definition_water.tres"),
    "wall": preload("res://assets/definitions/tiles/map_tiles/tile_definition_wall.tres"),
    "floor": preload("res://assets/definitions/tiles/map_tiles/tile_definition_floor.tres")
}

var tile_name: String
var _definition: TileDefinition
var player: Entity
var location_map: MapData

var is_explored: bool = false:
	set(value):
		is_explored = value
		if is_explored and not visible:
			visible = true

var is_in_view: bool = false:
	set(value):
		is_in_view = value
		modulate = _definition.color_lit if is_in_view else _definition.color_dark
		if is_in_view and not is_explored:
			is_explored = true

var key: String


func _init(entity: Entity, grid_position: Vector2i, key: String) -> void:
	visible = false
	centered = false
	player = entity
	position = Grid.grid_to_world(grid_position)
	set_tile_type(key)


func set_tile_type(key: String) -> void:
	self.key = key
	_definition = tile_types[key]
	tile_name = _definition.tile_name
	texture = _definition.texture
	modulate = _definition.color_dark
	if _definition.overworld_tile == false:
		_definition.persistent = false

func is_overworld() -> bool:
	return _definition.overworld_tile

func is_persistent() -> bool:
	return _definition.persistent

func is_walkable() -> bool:
	return _definition.is_walkable

func is_transparent() -> bool:
	return _definition.is_transparent

func get_grid_position() -> Vector2i:
	return Grid.world_to_grid(position)

func get_save_data() -> Dictionary:
	return {
		"key": key,
		"is_explored": is_explored,
	}


func restore(save_data: Dictionary) -> void:
	set_tile_type(save_data["key"])
	is_explored = save_data["is_explored"]
