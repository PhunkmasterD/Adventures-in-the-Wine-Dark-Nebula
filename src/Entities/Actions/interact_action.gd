class_name InteractAction
extends Action

var prop: Entity

func _init(entity: Entity, interact_prop: Entity) -> void:
	super._init(entity)
	prop = interact_prop

func perform() -> bool:
	if prop == null:
		return false
	return prop.interactable_component.activate(self)
