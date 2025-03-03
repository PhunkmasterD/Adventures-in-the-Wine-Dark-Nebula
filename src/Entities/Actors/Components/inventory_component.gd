class_name InventoryComponent
extends Component

# Array to store items and variable for inventory capacity
var items: Array[Entity]
var capacity: int

# Initialize the inventory with a specified capacity
func _init(capacity: int) -> void:
	items = []
	self.capacity = capacity

# Drop an item from the inventory
func drop(item: Entity) -> void:
	# Remove the item from the inventory
	items.erase(item)
	# Retrieve the map data
	var map_data: MapData = get_map_data()
	# Add the item to the map and update its position
	map_data.entities.append(item)
	map_data.entity_placed.emit(item)
	item.map_data = map_data
	item.grid_position = entity.grid_position
	# Send a message indicating the item was dropped
	MessageLog.send_message("You dropped the %s." % item.get_entity_name(), Color.WHITE)

# Get the save data for the inventory component
func get_save_data() -> Dictionary:
	var save_data: Dictionary = {
		"capacity": capacity,
		"items": []
	}
	# Save the data for each item in the inventory
	for item in items:
		save_data["items"].append(item.get_save_data())
	return save_data

# Restore the inventory component state from save data
func restore(save_data: Dictionary) -> void:
	capacity = save_data["capacity"]
	# Restore each item in the inventory from saved data
	for item_data in save_data["items"]:
		var item: Entity = Entity.new(null, Vector2i(-1, -1), "")
		item.restore(item_data)
		items.append(item)
