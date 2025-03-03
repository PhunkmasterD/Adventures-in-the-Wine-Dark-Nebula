class_name PickupAction
extends Action

# Perform the pickup action
func perform() -> bool:
	# Get the inventory component of the entity
	var inventory: InventoryComponent = entity.inventory_component
	# Retrieve the map data
	var map_data: MapData = get_map_data()
	
	# Iterate through the items on the map
	for item in map_data.get_items():
		# Check if the entity's position matches the item's position
		if entity.grid_position == item.grid_position:
			# If the inventory is full, send a message and return false
			if inventory.items.size() >= inventory.capacity:
				MessageLog.send_message("Your inventory is full.", GameColors.IMPOSSIBLE)
				return false
			
			# Remove the item from the map and add it to the inventory
			map_data.entities.erase(item)
			item.get_parent().remove_child(item)
			inventory.items.append(item)
			# Send a message indicating the item was picked up
			MessageLog.send_message(
				"You picked up the %s!" % item.get_entity_name(),
				Color.WHITE
			)
			return true
	
	# If no item was found, send a message indicating there is nothing to pick up
	MessageLog.send_message("There is nothing here to pick up.", GameColors.IMPOSSIBLE)
	return false
