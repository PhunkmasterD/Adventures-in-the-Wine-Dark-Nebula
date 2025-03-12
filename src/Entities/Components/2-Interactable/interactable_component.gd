class_name InteractableComponent
extends Component

func get_action(interactor: Entity) -> Action:
	return InteractAction.new(interactor, entity)

func activate(action: InteractAction) -> bool:
	return false

func destroy() -> void:
	var map_data = get_map_data()
	map_data.erase(entity)
	entity.queue_free()
