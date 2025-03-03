class_name LightningDamageConsumableComponent
extends ConsumableComponent

# Variables for damage and maximum range of the lightning
var damage: int = 0
var maximum_range: int = 0

# Initialize the component with the definition data
func _init(definition: LightningDamageConsumableComponentDefinition) -> void:
	damage = definition.damage
	maximum_range = definition.maximum_range

# Activate the lightning effect
func activate(action: ItemAction) -> bool:
	# Get the consumer entity
	var consumer: Entity = action.entity
	var target: Entity = null
	var closest_distance: float = maximum_range + 1
	# Retrieve the map data
	var map_data: MapData = consumer.map_data
	
	# Find the closest target within range
	for actor in map_data.get_actors():
		if actor != consumer and map_data.get_tile(actor.grid_position).is_in_view:
			var distance: float = consumer.distance(actor.grid_position)
			if distance < closest_distance:
				target = actor
				closest_distance = distance
	
	# If a target is found, apply damage and send a message
	if target:
		MessageLog.send_message("A lightning bolt strikes %s with a loud thunder, for %d damage!" % [target.get_entity_name(), damage], Color.WHITE)
		target.fighter_component.take_damage(damage)
		consume(consumer)
		return true
	
	# If no target is found, send a message indicating no enemies are in range
	MessageLog.send_message("No enemy is close enough to strike.", GameColors.IMPOSSIBLE)
	return false
