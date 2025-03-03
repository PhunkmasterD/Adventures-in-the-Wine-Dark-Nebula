class_name ItemAction
extends Action

# Declare variables for item and target position
var item: Entity
var target_position: Vector2i

# Initialize the ItemAction with entity, item, and optional target position
func _init(entity: Entity, item: Entity, target_position = null) -> void:
	# Call the parent class's _init method
	super._init(entity)
	self.item = item
	# If target_position is not provided, use the entity's grid position
	if not target_position is Vector2i:
		target_position = entity.grid_position
	# Set the target position
	self.target_position = target_position

# Get the actor at the target position
func get_target_actor() -> Entity:
	return get_map_data().get_actor_at_location(target_position)

# Perform the action, sorting between equippable and consumable items
func perform() -> bool:
	# Check if the item is null
	if item == null:
		return false
	# If the item is equippable, perform the EquipAction
	if item.equippable_component:
		return EquipAction.new(entity, item).perform()
	# Otherwise, activate the item's consumable component
	return item.consumable_component.activate(self)
