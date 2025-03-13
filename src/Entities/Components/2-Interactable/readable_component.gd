class_name ReadableComponent
extends InteractableComponent

# Variable to store information about the encoded text
var title: String
var text: String
var text_color: String
var image: Texture2D
var image_color: Color

# Initialize the component with the definition data
func _init(definition: ReadableComponentDefinition) -> void:
	print(" is a readable entity")
	title = definition.title
	text_color = definition.text_color.to_html()
	text = "[color=%s]%s[/color]" % [text_color, definition.text]

# Display the text in a dialog box
func activate(action: InteractAction) -> bool:
	image = entity.texture
	image_color = entity.modulate
	SignalBus.request_dialog.emit(title, text, image, image_color)
	return true
