class_name Entity
extends Sprite2D

# Enumeration for AI types
enum AIType {NONE, HOSTILE}

# Enumeration for Entity types
enum EntityType {CORPSE, ITEM, INTERACTABLE, ACTOR}

# Property for grid position with setter to update world position
var grid_position: Vector2i:
	set(value):
		grid_position = value
		var new_position = Grid.grid_to_world(grid_position)
		if self.get_parent() != null:
			tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
			tween.set_process_mode(tween.TWEEN_PROCESS_PHYSICS)
			tween.tween_property(self, "position", new_position, 0.05)
		else:
			position = new_position

# Variable declarations
var _definition: EntityDefinition
var entity_name: String
var blocks_movement: bool
var type: EntityType:
	set(value):
		type = value
		z_index = type
var map_data: MapData
var key: String
var tween: Tween


# Component variables
var fighter_component: FighterComponent
var ai_component: BaseAIComponent
var consumable_component: ConsumableComponent
var equippable_component: EquippableComponent
var inventory_component: InventoryComponent
var level_component: LevelComponent
var equipment_component: EquipmentComponent
var interactable_component: InteractableComponent

# Initialization function
func _init(get_map_data: MapData, start_position: Vector2i, get_key: String = "") -> void:
	# Set initial properties
	centered = false
	grid_position = start_position
	map_data = get_map_data
	# Set entity type if key is provided
	if get_key != "":
		set_entity_type(get_key)
	SignalBus.clear_orphan_nodes.connect(_on_clear_orphan_nodes)

# Function to set the entity type based on the key
func set_entity_type(get_key: String) -> void:
	key = get_key
	var entity_definition: EntityDefinition = load(EntityDictionary.entity_definitions[key])
	for child in get_children():
		if child != self and child.get_class() != "Camera2D":
			child.queue_free()
	_definition = entity_definition
	type = _definition.type
	if key == "player":
		z_index += 1
	blocks_movement = _definition.is_blocking_movment
	entity_name = _definition.name
	texture = entity_definition.texture
	modulate = entity_definition.color
	
	
	# Initialize AI component if applicable
	match entity_definition.ai_type:
		AIType.HOSTILE:
			ai_component = HostileEnemyAIComponent.new()
			add_child(ai_component)

	# Initialize fighter component if applicable
	if entity_definition.fighter_definition:
		fighter_component = FighterComponent.new(entity_definition.fighter_definition)
		add_child(fighter_component)

	# Initialize interactable component if applicable
	var interactable_definition: InteractableComponentDefinition = entity_definition.interactable_definition
	if interactable_definition:
		if interactable_definition is ReadableComponentDefinition:
			interactable_component = ReadableComponent.new(interactable_definition)
			add_child(interactable_component)
		if interactable_definition is TeleporterComponentDefinition:
			interactable_component = TeleporterComponent.new(interactable_definition)
			add_child(interactable_component)

		
	# Initialize item component if applicable
	var item_definition: ItemComponentDefinition = entity_definition.item_definition
	if item_definition:
		if item_definition is ConsumableComponentDefinition:
			_handle_consumable(item_definition)
		else:
			equippable_component = EquippableComponent.new(item_definition)
			add_child(equippable_component)
	
	# Initialize inventory component if applicable
	if entity_definition.inventory_capacity > 0:
		inventory_component = InventoryComponent.new(entity_definition.inventory_capacity)
		add_child(inventory_component)
	
	# Initialize level component if applicable
	if entity_definition.level_info:
		level_component = LevelComponent.new(entity_definition.level_info)
		add_child(level_component)
	
	# Initialize equipment component if applicable
	if entity_definition.has_equipment:
		equipment_component = EquipmentComponent.new()
		add_child(equipment_component)
		equipment_component.entity = self

# Function to move the entity by a given offset
func move(move_offset: Vector2i) -> void:
	map_data.unregister_blocking_entity(self)
	grid_position += move_offset
	map_data.register_blocking_entity(self)
	visible = map_data.get_tile(grid_position).is_in_view

# Function to calculate distance to another position
func distance(other_position: Vector2i) -> int:
	var relative: Vector2i = other_position - grid_position
	return maxi(abs(relative.x), abs(relative.y))

# Function to check if the entity blocks movement
func is_blocking_movement() -> bool:
	return blocks_movement

# Function to get the entity name
func get_entity_name() -> String:
	return entity_name

# Function to get the entity type
func get_entity_type() -> int:
	return _definition.type

# Function to check if the entity is alive
func is_alive() -> bool:
	return ai_component != null

# Function to handle consumable components
func _handle_consumable(consumable_definition: ConsumableComponentDefinition) -> void:
	# Initialize appropriate consumable component based on definition
	if consumable_definition is HealingConsumableComponentDefinition:
		consumable_component = HealingConsumableComponent.new(consumable_definition)
	elif consumable_definition is LightningDamageConsumableComponentDefinition:
		consumable_component = LightningDamageConsumableComponent.new(consumable_definition)
	elif consumable_definition is ConfusionConsumableComponentDefinition:
		consumable_component = ConfusionConsumableComponent.new(consumable_definition)
	elif consumable_definition is FireballDamageConsumableComponentDefinition:
		consumable_component = FireballDamageConsumableComponent.new(consumable_definition)
	
	# Add consumable component as a child
	if consumable_component:
		add_child(consumable_component)
	consumable_component.entity = self

# Function to get save data for the entity
func get_save_data() -> Dictionary:
	var save_data: Dictionary = {
		"x": grid_position.x,
		"y": grid_position.y,
		"key": key,
	}
	# Add component save data if applicable
	if fighter_component:
		save_data["fighter_component"] = fighter_component.get_save_data()
	if ai_component:
		save_data["ai_component"] = ai_component.get_save_data()
	if inventory_component:
		save_data["inventory_component"] = inventory_component.get_save_data()
	if equipment_component:
		save_data["equipment_component"] = equipment_component.get_save_data()
	if level_component:
		save_data["level_component"] = level_component.get_save_data()
	return save_data

# Function to restore entity from save data
func restore(save_data: Dictionary) -> void:
	grid_position = Vector2i(save_data["x"], save_data["y"])
	set_entity_type(save_data["key"])
	# Restore component data if applicable
	if fighter_component and save_data.has("fighter_component"):
		fighter_component.restore(save_data["fighter_component"])
	if ai_component and save_data.has("ai_component"):
		var ai_data: Dictionary = save_data["ai_component"]
		if ai_data["type"] == "ConfusedEnemyAI":
			var confused_enemy_ai := ConfusedEnemyAIComponent.new(ai_data["turns_remaining"])
			add_child(confused_enemy_ai)
	if inventory_component and save_data.has("inventory_component"):
		inventory_component.restore(save_data["inventory_component"])
	if equipment_component and save_data.has("equipment_component"):
		equipment_component.restore(save_data["equipment_component"])
	if level_component and save_data.has("level_component"):
		level_component.restore(save_data["level_component"])

func _on_clear_orphan_nodes():
	if self.get_parent() == null:
		queue_free()
