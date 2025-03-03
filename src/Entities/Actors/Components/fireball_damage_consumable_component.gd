class_name FireballDamageConsumableComponent
extends ConsumableComponent

# Variables for damage and radius of the fireball
var damage: int
var radius: int

# Initialize the component with the definition data
func _init(definition: FireballDamageConsumableComponentDefinition):
	damage = definition.damage
	radius = definition.radius

# Activate the fireball effect
func activate(action: ItemAction) -> bool:
	# Get the consumer and target position
	var consumer: Entity = action.entity
	var target_position: Vector2i = action.target_position
	# Retrieve the map data
	var map_data: MapData = consumer.map_data
	
	# Check if the target position is in view
	if not map_data.get_tile(target_position).is_in_view:
		MessageLog.send_message("You cannot target an area that you cannot see.", GameColors.IMPOSSIBLE)
		return false
	
	# Find all actors within the radius
	var targets := []
	for actor in map_data.get_actors():
		if actor.distance(target_position) <= radius:
			targets.append(actor)
	
	# If no targets are found, send a message
	if targets.is_empty():
		MessageLog.send_message("There are no targets in the radius.", GameColors.IMPOSSIBLE)
		return false

	# If only the player is in the radius, send a message and abort the cast
	if targets.size() == 1 and targets[0] == map_data.player:
		MessageLog.send_message("There are not enemy targets in the radius.", GameColors.IMPOSSIBLE)
		return false
	
	# Apply damage to each target and send a message
	for target in targets:
		MessageLog.send_message("The %s is engulfed in a fiery explosion, taking %d damage!" % [target.get_entity_name(), damage], GameColors.PLAYER_ATTACK)
		target.fighter_component.take_damage(damage)
	
	# Consume the item
	consume(action.entity)
	return true

# Get the targeting radius for the fireball effect
func get_targeting_radius() -> int:
	return radius
