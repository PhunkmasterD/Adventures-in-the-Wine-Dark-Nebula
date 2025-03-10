class_name InventoryMenu
extends CanvasLayer

# Signal emitted when an item is selected
signal item_selected(item)

# Preload the inventory menu item scene
const inventory_menu_item_scene := preload("res://src/GUI/InventorMenu/inventory_menu_item.tscn")

# Onready variables to reference UI elements
@onready var inventory_list: VBoxContainer = $"%InventoryList"
@onready var title_label: Label = $"%TitleLabel"
@onready var equipment_list: VBoxContainer = $"%EquipmentList"

# Called when the node is added to the scene
func _ready() -> void:
	# Hide the inventory menu initially
	hide()

# Function to build the inventory menu
func build(title_text: String, inventory: InventoryComponent) -> void:
	# If the inventory is empty, log a message and return
	if inventory.items.is_empty():
		button_pressed.call_deferred()
		MessageLog.send_message("No items in inventory.", GameColors.IMPOSSIBLE)
		return
	# Get the equipment component of the entity
	var equipment: EquipmentComponent = inventory.entity.equipment_component
	title_label.text = title_text
	
	# Create a dictionary to store item stacks
	var item_stacks := {}
	var equipped_item := {}

	# Loop through the inventory items and populate the item stacks dictionary
	for item in inventory.items:
		var item_name = item.get_entity_name()
		var is_equipped = equipment.is_item_equipped(item)
		if is_equipped:
			var item_slot = item.equippable_component.equipment_type
			equipped_item[item_slot] = item
		elif item_stacks.has(item_name):
			item_stacks[item_name].count += 1
		else:
			item_stacks[item_name] = { "item": item, "count": 1 }
	
	equipped_item.sort()
	# Loop through the item stacks and register each stack
	var index = 0
	for item_name in item_stacks.keys():
		var stack = item_stacks[item_name]
		var item = stack.item
		var count = stack.count
		_register_item(index, item, false, count)
		index += 1
	
	index = 0
	for equipment_name in equipped_item.keys():
		var item = equipped_item[equipment_name]
		var slot: String = item.equippable_component.equipment_dictionary[item.equippable_component.equipment_type]
		_register_equipment(item, slot)
		index += 1


	# Set focus to the first item in the inventory list
	if equipment_list.get_child_count() > 0:
		equipment_list.get_child(0).grab_focus()

	if inventory_list.get_child_count() > 0:
		inventory_list.get_child(0).grab_focus()
	show()

# Function to register an item in the inventory menu
func _register_item(index: int, item: Entity, is_equipped: bool, count: int) -> void:
	# Instantiate a new item button from the scene
	var item_button: Button = inventory_menu_item_scene.instantiate()
	# Create a character shortcut for the item
	var char: String = String.chr("a".unicode_at(0) + index)
	item_button.text = "( %s ) %s x%d" % [char, item.get_entity_name(), count]
	# Append "(E)" if the item is equipped
	if is_equipped:
		item_button.text += " (E)"
	# Create a shortcut event for the item button
	var shortcut_event := InputEventKey.new()
	shortcut_event.keycode = KEY_A + index
	item_button.icon = item.texture
	item_button.modulate = item.modulate
	item_button.shortcut = Shortcut.new()
	item_button.shortcut.events = [shortcut_event]
	# Connect the button pressed signal to the button_pressed function
	item_button.pressed.connect(button_pressed.bind(item))
	# Add the item button to the inventory list
	inventory_list.add_child(item_button)
	
# Function to register an item in the inventory menu
func _register_equipment(item: Entity, slot: String) -> void:
	var item_button: Button = inventory_menu_item_scene.instantiate()
	# Instantiate a new item button from the scene
	# Create a character shortcut for the item
	item_button.icon = item.texture
	item_button.modulate = item.modulate
	item_button.text = "%s: %s" % [slot, item.get_entity_name()]
	# Connect the button pressed signal to the button_pressed function
	item_button.pressed.connect(button_pressed.bind(item))
	# Add the item button to the inventory list
	equipment_list.add_child(item_button)

# Function called every physics frame
func _physics_process(_delta: float) -> void:
	# If the back action is pressed, emit the item_selected signal with null and free the menu
	if Input.is_action_just_pressed("ui_back"):
		item_selected.emit(null)
		queue_free()

# Function called when an item button is pressed
func button_pressed(item: Entity = null) -> void:
	# Emit the item_selected signal with the selected item and free the menu
	item_selected.emit(item)
	queue_free()
