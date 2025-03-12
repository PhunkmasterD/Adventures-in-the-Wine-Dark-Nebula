class_name ReturnToOverworld
extends Action

# Perform the action to return to the overworld
func perform() -> bool:
	# Send a message indicating the player is returning to the overworld
	var message = "You continue to journey across the land"
	MessageLog.send_message(message, GameColors.DESCEND)
	# Emit signals to handle the return to the overworld
	SignalBus.return_to_overworld.emit()
	SignalBus.overworld_input.emit()
	return false
