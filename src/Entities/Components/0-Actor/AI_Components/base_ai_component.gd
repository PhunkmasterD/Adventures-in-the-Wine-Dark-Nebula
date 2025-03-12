class_name BaseAIComponent
extends Component

# Perform the AI action (to be overridden by subclasses)
func perform() -> void:
	pass

# Get the path to a destination point
func get_point_path_to(destination: Vector2i) -> PackedVector2Array:
	# Use the map data's pathfinder to get the path from the entity's position to the destination
	return get_map_data().pathfinder.get_point_path(entity.grid_position, destination)

# Get the save data for the AI component
func get_save_data() -> Dictionary:
	# Return an empty dictionary (to be overridden by subclasses if needed)
	return {}
