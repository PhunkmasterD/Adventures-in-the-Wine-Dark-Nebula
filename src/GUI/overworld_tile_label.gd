extends Label

#set the text of the overworld tile
func set_overworld_tile_text(current_tile: String) -> void:
	text = "Current Tile: %s" % current_tile
