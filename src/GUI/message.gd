class_name Message
extends Label

const base_label_settings: LabelSettings = preload("res://assets/fonts/body_font.tres")

var plain_text: String
var count: int = 1:
	set(value):
		count = value
		# Update the label text with the full message text
		text = full_text()

# Initialization function for the message
func _init(msg_text: String, foreground_color: Color) -> void:
	plain_text = msg_text
	# Duplicate the base label settings and set the font color
	label_settings = base_label_settings.duplicate()
	label_settings.font_color = foreground_color
	# Set the initial text and enable word wrapping
	text = plain_text
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

# Function to get the full message text, including the count if greater than 1
func full_text() -> String:
	if count > 1:
		return "%s (x%d)" % [plain_text, count]
	return plain_text
