class_name ConfusedEnemyAIComponent
extends BaseAIComponent

# Variables to store the previous AI component and the number of turns remaining
var previous_ai: BaseAIComponent
var turns_remaining: int

# Ready function to initialize the component
func _ready() -> void:
	# Store the previous AI component and set the current AI component to this one
	previous_ai = entity.ai_component
	entity.ai_component = self

# Initialize the component with the number of turns remaining
func _init(turns_remaining: int) -> void:
	self.turns_remaining = turns_remaining

# Perform the confused AI action
func perform() -> void:
	# If no turns are remaining, revert to the previous AI component
	if turns_remaining <= 0:
		MessageLog.send_message("The %s is no longer confused." % entity.get_entity_name(), Color.WHITE)
		entity.ai_component = previous_ai
		queue_free()
	else:
		# Pick a random direction and perform a bump action
		var direction: Vector2i = [
			Vector2i(-1, -1),
			Vector2i( 0, -1),
			Vector2i( 1, -1),
			Vector2i(-1,  0),
			Vector2i( 1,  0),
			Vector2i(-1,  1),
			Vector2i( 0,  1),
			Vector2i( 1,  1),
		].pick_random()
		turns_remaining -= 1
		return BumpAction.new(entity, direction.x, direction.y).perform()

# Get the save data for the confused AI component
func get_save_data() -> Dictionary:
	return {
		"type": "ConfusedEnemyAI",
		"turns_remaining": turns_remaining
	}
