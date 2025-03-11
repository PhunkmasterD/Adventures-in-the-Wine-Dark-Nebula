extends BaseInputHandler

signal player_moved(current_tile_name: String)

const directions = {
	"move_up": Vector2i.UP,
	"move_down": Vector2i.DOWN,
	"move_left": Vector2i.LEFT,
	"move_right": Vector2i.RIGHT,
	"move_up_left": Vector2i.UP + Vector2i.LEFT,
	"move_up_right": Vector2i.UP + Vector2i.RIGHT,
	"move_down_left": Vector2i.DOWN + Vector2i.LEFT,
	"move_down_right": Vector2i.DOWN + Vector2i.RIGHT,
}

const inventory_menu_scene = preload("res://src/GUI/InventorMenu/inventory_menu.tscn")

@export var reticle: Reticle

func get_action(player: Entity) -> Action:
	var action: Action = null
	
	for direction in directions:
		if Input.is_action_just_pressed(direction):
			overworld_movement(player)
			var offset: Vector2i = directions[direction]
			action = OverworldMovementAction.new(player, offset.x, offset.y)
			action.timer = 0.2
		elif Input.is_action_pressed(direction):
			overworld_movement(player)
			var offset: Vector2i = directions[direction]
			action = OverworldMovementAction.new(player, offset.x, offset.y)
			action.timer = 0.01
	
	if Input.is_action_just_pressed("wait"):
		print(Dice.opposed_skill_check(player.fighter_component.power, false, player.fighter_component.power, false))
		action = WaitAction.new(player)
	
	if Input.is_action_just_pressed("view_history"):
		get_parent().transition_to(InputHandler.InputHandlers.HISTORY_VIEWER)
	
	if Input.is_action_just_pressed("look"):
		await get_grid_position(player, 0)    

	if Input.is_action_just_pressed("activate"):
		action = await activate_item(player)

	if Input.is_action_just_pressed("descend"):
		var exploration_tile = player.map_data.get_tile(player.grid_position)
		action = ExploreTileAction.new(player, player.grid_position, exploration_tile)
	
	if Input.is_action_just_pressed("quit") or Input.is_action_just_pressed("ui_back"):
		action = EscapeAction.new(player)
	
	if Input.is_action_just_pressed("zoom_in"):
		print("zooming in")
		SignalBus.zoom_changed.emit(false, 0.25)

	if Input.is_action_just_pressed("zoom_out"):
		print("zooming out")
		SignalBus.zoom_changed.emit(false, -0.25)

	if Input.is_action_just_pressed("reset_zoom"):
		print("resetting zoom")
		SignalBus.zoom_changed.emit(true, 0)
	return action

func overworld_movement(player: Entity) -> String:
	var movement_tile = player.map_data.get_tile(player.grid_position)
	var movement_tile_name = movement_tile.tile_name
	player_moved.emit(movement_tile_name)
	return movement_tile_name

func get_grid_position(player: Entity, radius: int) -> Vector2i:
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	var selected_position: Vector2i = await reticle.select_position(player, radius)
	await get_tree().physics_frame
	get_parent().call_deferred("transition_to", InputHandler.InputHandlers.OVERWORLD)
	return selected_position

func activate_item(player: Entity) -> Action:
	var selected_item: Entity = await get_item("Select an item to use", player.inventory_component, true)
	if selected_item == null:
		return null
	var target_radius: int = -1
	if selected_item.consumable_component != null:
		target_radius = selected_item.consumable_component.get_targeting_radius()
	if target_radius == -1:
		return ItemAction.new(player, selected_item)
	var target_position: Vector2i = await get_grid_position(player, target_radius)
	if target_position == Vector2i(-1, -1):
		return null
	return ItemAction.new(player, selected_item, target_position)


func get_item(window_title: String, inventory: InventoryComponent, evaluate_for_next_step: bool = false) -> Entity:
	if inventory.items.is_empty():
		await get_tree().physics_frame
		MessageLog.send_message("No items in inventory.", GameColors.IMPOSSIBLE)
		return null
	var inventory_menu: InventoryMenu = inventory_menu_scene.instantiate()
	add_child(inventory_menu)
	inventory_menu.build(window_title, inventory)
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	var selected_item: Entity = await inventory_menu.item_selected
	var has_item: bool = selected_item != null
	var needs_targeting: bool = has_item and selected_item.consumable_component and selected_item.consumable_component.get_targeting_radius() != -1
	if not evaluate_for_next_step or not has_item or not needs_targeting:
		await get_tree().physics_frame
		get_parent().call_deferred("transition_to", InputHandler.InputHandlers.OVERWORLD)
	return selected_item
