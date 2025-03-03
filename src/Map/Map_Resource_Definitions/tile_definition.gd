class_name TileDefinition
extends Resource

@export_category("Info")
@export var tile_name: String

@export_category("Overworld")
@export var overworld_tile: bool = false
@export var persistent: bool = false

@export_category("Visuals")
@export var texture: AtlasTexture
@export_color_no_alpha var color_lit: Color = Color.WHITE
@export_color_no_alpha var color_dark: Color = Color.WHITE

@export_category("Mechanics")
@export var is_walkable: bool = true
@export var is_transparent: bool = true
