class_name EquipmentComponent
extends Component

# Signal emitted when equipment changes
signal equipment_changed

# Dictionary to store equipment slots
var slots := {}

# Get the total defense bonus from equipped items
func get_defense_bonus() -> int:
	var bonus = 0
	
	# Iterate through equipped items and sum their defense bonuses
	for item in slots.values():
		if item.equippable_component:
			bonus += item.equippable_component.defense_bonus
	
	return bonus

# Get the total power bonus from equipped items
func get_power_bonus() -> int:
	var bonus = 0
	
	# Iterate through equipped items and sum their power bonuses
	for item in slots.values():
		if item.equippable_component:
			bonus += item.equippable_component.power_bonus
	
	return bonus

# Check if an item is equipped
func is_item_equipped(item: Entity) -> bool:
	return item in slots.values()

# Equip an item to a specified slot
func _equip_to_slot(slot: EquippableComponent.EquipmentType, item: Entity, add_message: bool) -> void:
	var current_item = slots.get(slot)
	# Unequip the current item in the slot if there is one
	if current_item:
		_unequip_from_slot(slot, add_message)
	# Equip the new item to the slot
	slots[slot] = item
	# Send a message if required
	if add_message:
		MessageLog.send_message("You equip the %s." % item.get_entity_name(), Color.WHITE)
	
	# Emit the equipment changed signal
	equipment_changed.emit()

# Unequip an item from a specified slot
func _unequip_from_slot(slot: EquippableComponent.EquipmentType, add_message: bool) -> void:
	var current_item = slots.get(slot)
	
	# Send a message if required
	if add_message:
		MessageLog.send_message("You remove the %s." % current_item.get_entity_name(), Color.WHITE)
	
	# Remove the item from the slot
	slots.erase(slot)
	
	# Emit the equipment changed signal
	equipment_changed.emit()

# Toggle the equip state of an item
func toggle_equip(equippable_item: Entity, add_message: bool = true) -> void:
	# Check if the item is equippable
	if not equippable_item.equippable_component:
		return
	var slot: EquippableComponent.EquipmentType = equippable_item.equippable_component.equipment_type
	
	# If the item is already equipped, unequip it; otherwise, equip it
	if slots.get(slot) == equippable_item:
		_unequip_from_slot(slot, add_message)
	else:
		_equip_to_slot(slot, equippable_item, add_message)

# Get the save data for the equipment component
func get_save_data() -> Dictionary:
	var equipped_indices := []
	var inventory: InventoryComponent = entity.inventory_component
	# Iterate through the inventory and record the indices of equipped items
	for i in inventory.items.size():
		var item: Entity = inventory.items[i]
		if is_item_equipped(item):
			equipped_indices.append(i)
	return {"equipped_indices": equipped_indices}

# Restore the equipment state from save data
func restore(save_data: Dictionary) -> void:
	var equipped_indices: Array = save_data["equipped_indices"]
	var inventory: InventoryComponent = entity.inventory_component
	# Iterate through the inventory and re-equip items based on saved indices
	for i in inventory.items.size():
		if equipped_indices.any(func(index): return int(index) == i):
			var item: Entity = inventory.items[i]
			toggle_equip(item, false)
