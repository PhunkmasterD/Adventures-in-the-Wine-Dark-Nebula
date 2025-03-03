class_name InventoryMenu
extends CanvasLayer

# Signal emitted when an item is selected
signal item_selected(item)

# Preload the inventory menu item scene
const inventory_menu_item_scene := preload("res://src/GUI/InventorMenu/inventory_menu_item.tscn")

# Onready variables to reference UI elements
@onready var inventory_list: VBoxContainer = $"%InventoryList"
@onready var title_label: Label = $"%TitleLabel"

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
	# Loop through the inventory items and register each item
	for i in inventory.items.size():
		var item: Entity = inventory.items[i]
		var is_equipped: bool = equipment.is_item_equipped(item)
		_register_item(i, item, is_equipped)
	# Set focus to the first item in the inventory list
	inventory_list.get_child(0).grab_focus()
	show()

# Function to register an item in the inventory menu
func _register_item(index: int, item: Entity, is_equipped: bool) -> void:
	# Instantiate a new item button from the scene
	var item_button: Button = inventory_menu_item_scene.instantiate()
	# Create a character shortcut for the item
	var char: String = String.chr("a".unicode_at(0) + index)
	item_button.text = "( %s ) %s" % [char, item.get_entity_name()]
	# Append "(E)" if the item is equipped
	if is_equipped:
		item_button.text += " (E)"
	# Create a shortcut event for the item button
	var shortcut_event := InputEventKey.new()
	shortcut_event.keycode = KEY_A + index
	item_button.shortcut = Shortcut.new()
	item_button.shortcut.events = [shortcut_event]
	# Connect the button pressed signal to the button_pressed function
	item_button.pressed.connect(button_pressed.bind(item))
	# Add the item button to the inventory list
	inventory_list.add_child(item_button)

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
