# This class handles the main game logic, including starting a new game, loading an existing game,
# and responding to escape key events to request the main menu.

class_name GameRoot
extends Control

signal main_menu_requested

@onready var game: Game = $"%Game"

# Called when the node is added to the scene.
func _ready() -> void:
	# Connect the escape_requested signal to the _on_escape_requested function.
	SignalBus.escape_requested.connect(_on_escape_requested)

# Handles the escape key press event.
func _on_escape_requested() -> void:
	main_menu_requested.emit()
	SignalBus.clear_orphan_nodes.emit()

# Starts a new game.
func new_game() -> void:
	game.new_game()

# Loads an existing game. If loading fails, emits the main_menu_requested signal.
func load_game() -> void:
	if not game.load_game():
		# If loading fails, emit the main_menu_requested signal.
		main_menu_requested.emit()
