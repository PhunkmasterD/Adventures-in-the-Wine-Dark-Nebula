class_name ConsumableComponent
extends Component

# Get the action associated with consuming the item
func get_action(consumer: Entity) -> Action:
	return ItemAction.new(consumer, entity)

# Activate the consumable item (to be overridden by subclasses)
func activate(action: ItemAction) -> bool:
	return false

# Consume the item and remove it from the inventory
func consume(consumer: Entity) -> void:
	# Get the inventory component of the consumer
	var inventory: InventoryComponent = consumer.inventory_component
	# Remove the item from the inventory and free it
	inventory.items.erase(entity)
	entity.queue_free()

# Get the targeting radius for the consumable item (default is -1, meaning no targeting)
func get_targeting_radius() -> int:
	return -1
