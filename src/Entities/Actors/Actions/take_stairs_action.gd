class_name TakeStairsAction
extends Action

# Perform the action to take the stairs
func perform() -> bool:
	# Check if the entity's position matches the down stairs location
	if entity.grid_position == get_map_data().down_stairs_location:
		# Emit a signal indicating the player has descended
		SignalBus.player_descended.emit()
		MessageLog.send_message("You descend the staircase.", GameColors.DESCEND)
	else:
		MessageLog.send_message("There are no stairs here.", GameColors.IMPOSSIBLE)
	return false
