class_name ActionWithDirection
extends Action

# Variable to store the direction offset
var offset: Vector2i

# Initialization function
func _init(entity: Entity, dx: int, dy: int) -> void:
	# Call the parent class initializer
	super._init(entity)
	# Set the direction offset
	offset = Vector2i(dx, dy)

# Function to get the destination based on the offset
func get_destination() -> Vector2i:
	return entity.grid_position + offset

# Function to get the blocking entity at the destination
func get_blocking_entity_at_destination() -> Entity:
	return get_map_data().get_blocking_entity_at_location(get_destination())

# Function to get the target actor at the destination
func get_target_actor() -> Entity:
	return get_map_data().get_actor_at_location(get_destination())
