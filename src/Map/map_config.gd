extends Node

# Variables for overworld generation settings
var world_map_width: int
var world_map_height: int
var world_map_depth: int
var num_biomes: int

# Variables for dungeon generation settings
var dungeon_map_width: int
var dungeon_map_height: int
var dungeon_max_rooms: int
var dungeon_room_max_size: int
var dungeon_room_min_size: int

# Ready function to load map configuration
func _ready() -> void:
    var config = load("res://assets/definitions/map/map_config.tres") as MapConfigDefinition
    if config:
        print("Successfully loaded map_config.tres map configuration")
        world_map_width = config.world_map_width
        world_map_height = config.world_map_height
        world_map_depth = config.world_map_depth
        num_biomes = config.num_biomes
        dungeon_map_width = config.dungeon_map_width
        dungeon_map_height = config.dungeon_map_height
        dungeon_max_rooms = config.dungeon_max_rooms
        dungeon_room_max_size = config.dungeon_room_max_size
        dungeon_room_min_size = config.dungeon_room_min_size
    else:
        print("Failed to load map_config.tres")