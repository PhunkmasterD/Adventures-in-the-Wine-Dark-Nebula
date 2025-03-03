class_name EscapeAction
extends Action

# Perform the escape action, exiting to the main menu
func perform() -> bool:
	#entity.get_tree().quit()
	SignalBus.escape_requested.emit()
	return false
