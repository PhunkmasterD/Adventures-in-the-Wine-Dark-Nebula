class_name EquipAction
extends Action

var _item: Entity

# Initialize the equip action
func _init(entity: Entity, item: Entity) -> void:
	super._init(entity)
	_item = item

# Toggles the equip of the action
func perform() -> bool:
	entity.equipment_component.toggle_equip(_item)
	return true
