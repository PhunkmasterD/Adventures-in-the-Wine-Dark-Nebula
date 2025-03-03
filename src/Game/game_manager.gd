extends Node

# Preload game and main menu scenes
const game_scene: PackedScene = preload("res://src/Game/game.tscn")
const main_menu_scene: PackedScene = preload("res://src/GUI/MainMenu/main_menu.tscn")

var current_child: Node

# Called when the node is added to the scene
func _ready():
	# Load the main menu scene
	load_main_menu()

# Load the main menu scene
func load_main_menu() -> void:
	# Switch to the main menu scene
	var main_menu: MainMenu = switch_to_scene(main_menu_scene)
	# Connect the game requested signal to the handler
	main_menu.game_requested.connect(_on_game_requested)

# Switch to a new scene
func switch_to_scene(scene: PackedScene) -> Node:
	# If there is a current child, free it
	if current_child != null:
		current_child.queue_free()
	# Instantiate the new scene and add it as a child
	current_child = scene.instantiate()
	add_child(current_child)
	# Return the new scene instance
	return current_child

# Handle the game requested signal
func _on_game_requested(try_load: bool) -> void:
	# Switch to the game scene
	var game: GameRoot = switch_to_scene(game_scene)
	# Connect the main menu requested signal to the handler
	game.main_menu_requested.connect(load_main_menu)
	# Load or start a new game based on the try_load flag
	if try_load:
		game.load_game()
	else:
		game.new_game()
