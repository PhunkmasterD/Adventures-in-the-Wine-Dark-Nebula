class_name ReturnToOverworld
extends Action

func perform() -> bool:
	var message = "You continue to journey across the land"
	MessageLog.send_message(message, GameColors.DESCEND)
	SignalBus.return_to_overworld.emit()
	SignalBus.overworld_input.emit()
	return false
