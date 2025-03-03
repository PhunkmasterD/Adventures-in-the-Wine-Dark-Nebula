class_name MessageLog
extends ScrollContainer

var last_message: Message = null

@onready var message_list: VBoxContainer = $"%MessageList"

# Ready function to connect signals
func _ready() -> void:
	# Connect the message_sent signal to add messages to the log
	SignalBus.message_sent.connect(add_message)

# Static function to send a message
static func send_message(text: String, color: Color) -> void:
	# Emit the message_sent signal with the text and color
	SignalBus.message_sent.emit(text, color)

# Function to add a message to the log
func add_message(text: String, color: Color) -> void:
	# Check if the last message is the same as the new message
	if (
		last_message != null and
		last_message.plain_text == text
	):
		# Increment the count of the last message
		last_message.count += 1
	else:
		# Create a new message and add it to the message list
		var message := Message.new(text, color)
		last_message = message
		message_list.add_child(message)
		# Ensure the new message is visible
		await get_tree().process_frame
		ensure_control_visible(message)
