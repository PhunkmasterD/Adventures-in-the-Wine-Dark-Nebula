class_name TileDefinition
extends Resource

# Tile information
@export_category("Info")
@export var tile_name: String

# Overworld properties
@export_category("Overworld")
@export var overworld_tile: bool = false
@export var persistent: bool = false

# Visual properties
@export_category("Visuals")
@export var texture: AtlasTexture
@export_color_no_alpha var color_lit: Color = Color.WHITE
@export_color_no_alpha var color_dark: Color = Color.WHITE

# Mechanical properties
@export_category("Mechanics")
@export var is_walkable: bool = true
@export var is_transparent: bool = true
