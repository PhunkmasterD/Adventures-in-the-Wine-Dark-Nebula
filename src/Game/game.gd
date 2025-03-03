class_name Game
extends Node2D

signal player_created(player)

const level_up_menu_scene: PackedScene = preload("res://src/GUI/LevelUpMenu/level_up_menu.tscn")

@onready var player: Entity
@onready var input_handler: InputHandler = $InputHandler
@onready var map: Map = $Map
@onready var camera: Camera2D = $Camera2D
@onready var action_cooldown: float

# Function to start a new game
func new_game() -> void:
	print("Initializing new game...")
	print("Creating player...")
	# Create player entity and add starting equipment
	player = Entity.new(null, Vector2i.ZERO, "player")
	_add_player_start_equipment("dagger")
	_add_player_start_equipment("leather_armor")
	# Emit signals and set up camera
	emit_signals()
	remove_child(camera)
	player.add_child(camera)
	# Generate the map and update field of view
	print("Creating map...")
	map.generate(player)
	map.update_fov(player.grid_position)
	# Send welcome message
	MessageLog.send_message.bind(
		"Hello and welcome, adventurer, to yet another dungeon!",
		GameColors.WELCOME_TEXT
	).call_deferred()
	camera.make_current.call_deferred()

# Function to emit necessary signals
func emit_signals() -> void:
	# Connect player level up signal and emit player created signal
	player.level_component.level_up_required.connect(_on_player_level_up_requested)
	player_created.emit(player)

# Function to add starting equipment to the player
func _add_player_start_equipment(item_key: String) -> void:
	# Create item entity and add to player's inventory and equipment
	var item := Entity.new(null, Vector2i.ZERO, item_key)
	player.inventory_component.items.append(item)
	player.equipment_component.toggle_equip(item, false)

# Function to load a saved game
func load_game() -> bool:
	print("Loading game...")
	print("Loading player...")
	# Create player entity and load map
	player = Entity.new(null, Vector2i.ZERO, "")
	if not map.load_game(player):
		print("Error: Map is not initialized, aborting...")
		return false
	# Check if player is initialized
	if player == null:
		print("Error: Player is not initialized, aborting...")
		return false
	# Set up camera and connect signals
	print("Player initialized...")
	remove_child(camera)
	player.add_child(camera)
	if player.level_component == null:
		print("Error: Player's level_component is not initialized.")
		return false
	player.level_component.level_up_required.connect(_on_player_level_up_requested)
	player_created.emit(player)
	# Update field of view and send welcome message
	map.update_fov(player.grid_position)
	MessageLog.send_message.bind(
		"Welcome back, adventurer!",
		GameColors.WELCOME_TEXT
	).call_deferred()
	camera.make_current.call_deferred()
	return true

# Function to handle physics processing
func _physics_process(delta: float) -> void:
	# Get action from input handler
	var action: Action = await input_handler.get_action(player)
	if action:
		# Perform action if cooldown is zero
		if action.cooldown == 0:
			if action.perform():
				_handle_enemy_turns()
				map.update_fov(player.grid_position)
		# Handle action cooldown
		elif action.cooldown > 0 and action_cooldown <= 0:
			action_cooldown = action.cooldown
			if action.perform():
				_handle_enemy_turns()
				map.update_fov(player.grid_position)
	action_cooldown -= delta

# Function to handle enemy turns
func _handle_enemy_turns() -> void:
	# Iterate through entities and perform AI actions
	for entity in get_map_data().entities:
		if entity.ai_component != null and entity != player:
			entity.ai_component.perform()

# Function to handle player level up requests
func _on_player_level_up_requested() -> void:
	# Instantiate and set up level up menu
	var level_up_menu: LevelUpMenu = level_up_menu_scene.instantiate()
	add_child(level_up_menu)
	level_up_menu.setup(player)
	# Pause physics processing during level up
	set_physics_process(false)
	await level_up_menu.level_up_completed
	set_physics_process.bind(true).call_deferred()

# Function to get the current map data
func get_map_data() -> MapData:
	return map.map_data
