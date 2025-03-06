extends Node

enum TileKey{
    MEADOW,
    FOREST,
    DOWN_STAIRS,
    WATER,
    WALL,
    FLOOR
}

# Dictionary to preload tile definitions
const tile_definitions = {
    TileKey.MEADOW: preload("res://assets/definitions/tiles/overworld/tile_definition_meadow.tres"),
    TileKey.FOREST: preload("res://assets/definitions/tiles/overworld/tile_definition_forest.tres"),
    TileKey.DOWN_STAIRS: preload("res://assets/definitions/tiles/map_tiles/tile_definition_down_stairs.tres"),
    TileKey.WATER: preload("res://assets/definitions/tiles/map_tiles/tile_definition_water.tres"),
    TileKey.WALL: preload("res://assets/definitions/tiles/map_tiles/tile_definition_wall.tres"),
    TileKey.FLOOR: preload("res://assets/definitions/tiles/map_tiles/tile_definition_floor.tres")
}
