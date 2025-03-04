class_name MovementAction
extends ActionWithDirection

# Perform the movement action
func perform() -> bool:
	# Get the destination position
	var destination: Vector2i = get_destination()
	
	# Retrieve the map data and the tile at the destination
	var map_data: MapData = get_map_data()
	var destination_tile: Tile = map_data.get_tile(destination)
	# Check if the destination tile is walkable and if there is no blocking entity
	if not destination_tile or not destination_tile.is_walkable() or get_blocking_entity_at_destination():
		# If the entity is the player, send a message indicating the way is blocked
		if entity == get_map_data().player:
			MessageLog.send_message("That way is blocked.", GameColors.IMPOSSIBLE)
		return false
	
	# Move the entity to the destination
	entity.move(offset)

	#set the action cooldown
	entity.fighter_component.action_cooldown = 1
	
	return true
