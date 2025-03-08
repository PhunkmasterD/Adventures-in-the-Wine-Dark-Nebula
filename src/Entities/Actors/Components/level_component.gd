class_name LevelComponent
extends Component

# Signals for level up events and experience changes
signal level_up_required
signal leveled_up
signal xp_changed(xp, max_xp)

# Variables for current level, experience, and level up parameters
var current_level: int = 1
var current_xp: int = 0
var level_up_base: int
var level_up_factor: int
var xp_given: int

# Initialize the component with the definition data
func _init(definition: LevelComponentDefinition) -> void:
	level_up_base = definition.level_up_base
	level_up_factor = definition.level_up_factor
	xp_given = definition.xp_given
	super._init()

func _on_clear_orphan_nodes():
	if self.get_parent() == null:
		queue_free()

# Get the experience required to reach the next level
func get_experience_to_next_level() -> int:
	return level_up_base + current_level * level_up_factor

# Check if a level up is required
func is_level_up_required() -> bool:
	return current_xp >= get_experience_to_next_level()

# Add experience points to the entity
func add_xp(xp: int) -> void:
	if xp == 0 or level_up_base == 0:
		return
	
	current_xp += xp
	MessageLog.send_message("You gain %d experience points." % xp, Color.WHITE)
	xp_changed.emit(current_xp, get_experience_to_next_level())
	if is_level_up_required():
		MessageLog.send_message("You advance to level %d!" % (current_level + 1), Color.WHITE)
		level_up_required.emit()

# Increase the entity's level
func increase_level() -> void:
	current_xp -= get_experience_to_next_level()
	current_level += 1
	xp_changed.emit(current_xp, get_experience_to_next_level())
	leveled_up.emit()

# Increase the entity's maximum HP
func increase_max_hp(amount: int = 20) -> void:
	var fighter: FighterComponent = entity.fighter_component
	fighter.max_hp += amount
	fighter.hp += amount
	
	MessageLog.send_message("Your health improves!", Color.WHITE)
	increase_level()

# Increase the entity's power
func increase_power(amount: int = 1) -> void:
	var fighter: FighterComponent = entity.fighter_component
	fighter.base_power += amount
	
	MessageLog.send_message("You feel stronger!", Color.WHITE)
	increase_level()

# Increase the entity's defense
func increase_defense(amount: int = 1) -> void:
	var fighter: FighterComponent = entity.fighter_component
	fighter.base_defense += amount
	
	MessageLog.send_message("Your movements are getting swifter!", Color.WHITE)
	increase_level()

# Get the save data for the level component
func get_save_data() -> Dictionary:
	return {
		"current_level": current_level,
		"current_xp": current_xp,
		"level_up_base": level_up_base,
		"level_up_factor": level_up_factor,
		"xp_given": xp_given
	}

# Restore the level component state from save data
func restore(save_data: Dictionary) -> void:
	current_level = save_data["current_level"]
	current_xp = save_data["current_xp"]
	level_up_base = save_data["level_up_base"]
	level_up_factor = save_data["level_up_factor"]
	xp_given = save_data["xp_given"]
