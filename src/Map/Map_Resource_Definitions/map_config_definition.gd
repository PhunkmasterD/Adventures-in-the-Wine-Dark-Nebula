class_name MapConfigDefinition
extends Resource

@export_category("Overworld Generation")
@export var world_map_width: int = 15
@export var world_map_height: int = 15
@export var world_map_depth: int = 5
@export var num_biomes: int = 10

@export_category("Dungeon Generation")
@export var dungeon_map_width: int = 80
@export var dungeon_map_height: int = 45
@export var dungeon_max_rooms: int = 30
@export var dungeon_room_max_size: int = 10
@export var dungeon_room_min_size: int = 6
