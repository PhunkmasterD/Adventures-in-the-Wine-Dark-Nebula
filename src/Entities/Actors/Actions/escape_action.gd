class_name EscapeAction
extends Action


func perform() -> bool:
	#entity.get_tree().quit()
	SignalBus.escape_requested.emit()
	return false
