class_name Game
extends Node2D

signal player_created(player)

const level_up_menu_scene: PackedScene = preload("res://src/GUI/LevelUpMenu/level_up_menu.tscn")

@onready var player: Entity
@onready var input_handler: InputHandler = $InputHandler
@onready var map: Map = $Map
@onready var camera: Camera2D = $Camera2D
@onready var action_cooldown: float

func new_game() -> void:
	print("Initializing new game...")
	print("Creating player...")
	player = Entity.new(null, Vector2i.ZERO, "player")
	_add_player_start_equipment("dagger")
	_add_player_start_equipment("leather_armor")
	emit_signals()
	remove_child(camera)
	player.add_child(camera)
	print("Creating map...")
	map.generate(player)
	map.update_fov(player.grid_position)
	MessageLog.send_message.bind(
		"Hello and welcome, adventurer, to yet another dungeon!",
		GameColors.WELCOME_TEXT
	).call_deferred()
	camera.make_current.call_deferred()

func emit_signals() -> void:
	player.level_component.level_up_required.connect(_on_player_level_up_requested)
	player_created.emit(player)

func _add_player_start_equipment(item_key: String) -> void:
	var item := Entity.new(null, Vector2i.ZERO, item_key)
	player.inventory_component.items.append(item)
	player.equipment_component.toggle_equip(item, false)

func load_game() -> bool:
	print("Loading game...")
	print("Loading player...")
	player = Entity.new(null, Vector2i.ZERO, "")
	if not map.load_game(player):
		print("Error: Map is not initialized, aborting...")
		return false

	if player == null:
		print("Error: Player is not initialized, aborting...")
		return false

	print("Player initialized...")
	remove_child(camera)
	player.add_child(camera)

	if player.level_component == null:
		print("Error: Player's level_component is not initialized.")
		return false

	player.level_component.level_up_required.connect(_on_player_level_up_requested)
	player_created.emit(player)
	map.update_fov(player.grid_position)
	MessageLog.send_message.bind(
		"Welcome back, adventurer!",
		GameColors.WELCOME_TEXT
	).call_deferred()
	camera.make_current.call_deferred()
	return true

func _physics_process(delta: float) -> void:
	var action: Action = await input_handler.get_action(player)
	if action:
		if action.cooldown == 0:
			if action.perform():
				_handle_enemy_turns()
				map.update_fov(player.grid_position)
		elif action.cooldown > 0 and action_cooldown <= 0:
			action_cooldown = action.cooldown
			if action.perform():
				_handle_enemy_turns()
				map.update_fov(player.grid_position)
	action_cooldown -= delta


func _handle_enemy_turns() -> void:
	for entity in get_map_data().entities:
		if entity.ai_component != null and entity != player:
			entity.ai_component.perform()


func _on_player_level_up_requested() -> void:
	var level_up_menu: LevelUpMenu = level_up_menu_scene.instantiate()
	add_child(level_up_menu)
	level_up_menu.setup(player)
	set_physics_process(false)
	await level_up_menu.level_up_completed
	set_physics_process.bind(true).call_deferred()


func get_map_data() -> MapData:
	return map.map_data
