class_name ConfusionConsumableComponent
extends ConsumableComponent

# Variable to store the number of turns the confusion effect lasts
var number_of_turns: int

# Initialize the component with the definition data
func _init(definition: ConfusionConsumableComponentDefinition) -> void:
	super._init()
	number_of_turns = definition.number_of_turns

# Activate the confusion effect on the target
func activate(action: ItemAction) -> bool:
	# Get the consumer and target entities
	var consumer: Entity = action.entity
	var target: Entity = action.get_target_actor()
	# Retrieve the map data
	var map_data: MapData = consumer.map_data
	
	# Check if the target position is in view
	if not map_data.get_tile(action.target_position).is_in_view:
		MessageLog.send_message("You cannot target an area that you cannot see.", GameColors.IMPOSSIBLE)
		return false
	# Check if there is a valid target
	if not target:
		MessageLog.send_message("You must select an enemy to target.", GameColors.IMPOSSIBLE)
		return false
	# Prevent the consumer from confusing themselves
	if target == consumer:
		MessageLog.send_message("You cannot confuse yourself!", GameColors.IMPOSSIBLE)
		return false
	
	# Apply the confusion effect to the target
	MessageLog.send_message("The eyes of the %s look vacant, as it starts to stumble around!" % target.get_entity_name(), GameColors.STATUS_EFFECT_APPLIED)
	target.add_child(ConfusedEnemyAIComponent.new(number_of_turns))
	# Consume the item
	consume(consumer)
	return true

# Get the targeting radius for the confusion effect
func get_targeting_radius() -> int:
	return 0

