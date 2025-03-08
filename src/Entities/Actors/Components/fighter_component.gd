class_name FighterComponent
extends Component

# Signal emitted when HP changes
signal hp_changed(hp, max_hp)

# Variables for max HP, current HP, base defense, and base power
var max_hp: int
var hp: int:
	set(value):
		hp = clampi(value, 0, max_hp)
		hp_changed.emit(hp, max_hp)
		if hp <= 0:
			var die_silently := false
			if not is_inside_tree():
				die_silently = true
				await ready
			die(not die_silently)
		elif hp <= max_hp / 2:
			# Adjust the blend factor to control the redness
			if entity:
				entity.modulate = entity.modulate.lerp(Color(1, 0, 0), 0.3)
var base_defense: int
var base_power: int
var agi: int
var action_cooldown: int = 0

# Computed properties for defense and power
var defense: int: 
	get:
		return base_defense + get_defense_bonus()
var power: int: 
	get:
		return base_power + get_power_bonus()

# Variables for death texture and color
var death_texture: Texture
var death_color: Color

# Initialize the component with the definition data
func _init(definition: FighterComponentDefinition) -> void:
	max_hp = definition.max_hp
	hp = definition.max_hp
	base_defense = definition.defense
	base_power = definition.power
	death_texture = definition.death_texture
	death_color = definition.death_color
	action_cooldown = 0
	super._init()

# Heal the entity by a specified amount
func heal(amount: int) -> int:
	if hp == max_hp:
		return 0
	
	var new_hp_value: int = hp + amount
	
	if new_hp_value > max_hp:
		new_hp_value = max_hp
		
	var amount_recovered: int = new_hp_value - hp
	hp = new_hp_value
	return amount_recovered

# Inflict damage to the entity
func take_damage(amount: int) -> void:
	hp -= amount

# Handle the entity's death
func die(trigger_side_effects := true) -> void:
	var death_message: String
	var death_message_color: Color
	
	if get_map_data().player == entity:
		death_message = "You died!"
		death_message_color = GameColors.PLAYER_DIE
		SignalBus.player_died.emit()
	else:
		death_message = "%s is dead!" % entity.get_entity_name()
		death_message_color = GameColors.ENEMY_DIE
	
	if trigger_side_effects:
		MessageLog.send_message(death_message, death_message_color)
		get_map_data().player.level_component.add_xp(entity.level_component.xp_given)
	if entity:
		entity.texture = death_texture
		entity.modulate = death_color
		if entity.ai_component:
			entity.ai_component.queue_free()
			entity.ai_component = null
		entity.entity_name = "Remains of %s" % entity.entity_name
		entity.blocks_movement = false
		entity.type = Entity.EntityType.CORPSE
		get_map_data().unregister_blocking_entity(entity)

# Get the defense bonus from equipped items
func get_defense_bonus() -> int:
	if entity.equipment_component:
		return entity.equipment_component.get_defense_bonus()
	return 0

# Get the power bonus from equipped items
func get_power_bonus() -> int:
	if entity.equipment_component:
		return entity.equipment_component.get_power_bonus()
	return 0

# Get the save data for the fighter component
func get_save_data() -> Dictionary:
	return {
		"max_hp": max_hp,
		"hp": hp,
		"power": base_power,
		"defense": base_defense
	}

# Restore the fighter component state from save data
func restore(save_data: Dictionary) -> void:
	max_hp = save_data["max_hp"]
	hp = save_data["hp"]
	base_power = save_data["power"]
	base_defense = save_data["defense"]
