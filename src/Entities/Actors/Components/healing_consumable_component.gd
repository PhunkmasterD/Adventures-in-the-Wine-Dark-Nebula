class_name HealingConsumableComponent
extends ConsumableComponent

# Variable to store the amount of healing
var amount: int

# Initialize the component with the definition data
func _init(definition: HealingConsumableComponentDefinition) -> void:
	amount = definition.healing_amount
	super._init()

# Activate the healing effect
func activate(action: ItemAction) -> bool:
	# Get the consumer entity
	var consumer: Entity = action.entity
	# Heal the consumer and get the amount recovered
	var amount_recovered: int = consumer.fighter_component.heal(amount)
	# If some HP was recovered, send a message and consume the item
	if amount_recovered > 0:
		MessageLog.send_message(
			"You consume the %s, and recover %d HP!" % [entity.get_entity_name(), amount_recovered],
			GameColors.HEALTH_RECOVERED
		)
		consume(consumer)
		return true
	# If no HP was recovered, send a message indicating health is full
	MessageLog.send_message("Your health is already full.", GameColors.IMPOSSIBLE)
	return false
