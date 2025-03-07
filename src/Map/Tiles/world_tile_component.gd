class_name WorldTileComponent
extends Tile

var persistent: bool 
var chunk: int

# Initialization function for tiles, setting up basic variables
func _init(_definition: WorldTileDefinition) -> void:
    persistent = _definition.is_persistent

# Function to check if the tile is persistent
func is_persistent() -> bool:
    return persistent