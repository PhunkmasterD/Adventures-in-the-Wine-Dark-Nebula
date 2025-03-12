class_name ReadableComponent
extends InteractableComponent

# Variable to store information about the encoded text
var title: String
var text: String
var text_color: String

# Initialize the component with the definition data
func _init(definition: ReadableComponentDefinition) -> void:
	title = definition.title
	text_color = definition.text_color.to_html()
	text = "[color=%s]%s[/color]" % [text_color, definition.text]

# Activate the healing effect
func activate(action: InteractAction) -> bool:
	SignalBus.request_dialog.emit(title, text)
	return true
