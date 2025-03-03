extends Label

# Function to set the dungeon floor label text
func set_dungeon_floor(current_tile: String) -> void:
	# Update the label text with the current tile information
	text = "Current Tile: %d" % current_tile
