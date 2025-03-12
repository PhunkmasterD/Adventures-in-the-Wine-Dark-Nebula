class_name DropItemAction
extends ItemAction

# Drops an item from the inventory
func perform() -> bool:
	if item == null:
		return false
	# Unequip the item if it is equipped first
	if entity.equipment_component and entity.equipment_component.is_item_equipped(item):
		entity.equipment_component.toggle_equip(item)
	entity.inventory_component.drop(item)
	return true
