class_name HostileEnemyAIComponent
extends BaseAIComponent

# Variable to store the path to the target
var path: Array = []

# Perform the hostile enemy AI action
func perform() -> void:
	# Get the player entity and its position
	var target: Entity = get_map_data().player
	var target_grid_position: Vector2i = target.grid_position
	# Calculate the offset and distance to the target
	var offset: Vector2i = target_grid_position - entity.grid_position
	var distance: int = max(abs(offset.x), abs(offset.y))
	
	# If the entity is in view, decide whether to attack or move towards the target
	if get_map_data().get_tile(entity.grid_position).is_in_view:
		if distance <= 1:
			return MeleeAction.new(entity, offset.x, offset.y).perform()
		
		# Calculate the path to the target
		path = get_point_path_to(target_grid_position)
		path.pop_front()
	
	# If there is a path, move towards the next point or wait if blocked
	if not path.is_empty():
		var destination := Vector2i(path[0])
		if get_map_data().get_blocking_entity_at_location(destination):
			return WaitAction.new(entity).perform()
		Vector2i(path.pop_front())
		var move_offset: Vector2i = destination - entity.grid_position
		return MovementAction.new(entity, move_offset.x, move_offset.y).perform()
	
	# If no action can be performed, wait
	return WaitAction.new(entity).perform()

# Get the save data for the hostile enemy AI
func get_save_data() -> Dictionary:
	return {"type": "HostileEnemyAI"}
