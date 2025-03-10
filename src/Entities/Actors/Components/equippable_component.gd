class_name EquippableComponent
extends Component

# Enum outlining the equipment types
enum EquipmentType { WEAPON, ARMOR }

var equipment_dictionary: Dictionary = {
	EquipmentType.WEAPON: "Weapon",
	EquipmentType.ARMOR: "Armor"
}

# Setting up equippable variables
var equipment_type: EquipmentType
var power_bonus: int
var defense_bonus: int

# Initialize the equippable component
func _init(definition: EquippableComponentDefinition) -> void:
	super._init()
	equipment_type = definition.equipment_type
	power_bonus = definition.power_bonus
	defense_bonus = definition.defense_bonus
