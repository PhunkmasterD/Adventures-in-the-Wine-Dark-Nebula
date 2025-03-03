# MainMenu class extends Control and handles the main menu UI
class_name MainMenu
extends Control

# Signal emitted when a new game or load game is requested
signal game_requested(load)

# References to the buttons in the scene
@onready var first_button: Button = $"%NewButton"
@onready var load_button: Button = $"%LoadButton"

# Called when the node is added to the scene
func _ready():
	# Set focus to the first button
	first_button.grab_focus()
	# Check if a save file exists and enable/disable the load button accordingly
	var has_save_file: bool = FileAccess.file_exists("user://maps_save.dat")
	load_button.disabled = not has_save_file

# Called when the new game button is pressed
func _on_new_button_pressed():
	# Emit the game_requested signal with 'false' indicating a new game
	game_requested.emit(false)

# Called when the load game button is pressed
func _on_load_button_pressed():
	# Emit the game_requested signal with 'true' indicating a load game
	game_requested.emit(true)

# Called when the quit button is pressed
func _on_quit_button_pressed():
	# Quit the game
	get_tree().quit()
