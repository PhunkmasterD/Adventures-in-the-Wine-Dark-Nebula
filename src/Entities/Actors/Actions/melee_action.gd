class_name MeleeAction
extends ActionWithDirection

# Perform the melee action
func perform() -> bool:
	# Get the target actor
	var target: Entity = get_target_actor()
	# If there is no target, send a message if the entity is the player
	if not target:
		if entity == get_map_data().player:
			MessageLog.send_message("Nothing to attack.", GameColors.IMPOSSIBLE)
		return false
	
	# Calculate the damage
	var damage: int = entity.fighter_component.power - target.fighter_component.defense
	# Determine the attack color based on whether the entity is the player or an enemy
	var attack_color: Color
	if entity == get_map_data().player:
		attack_color = GameColors.PLAYER_ATTACK
	else:
		attack_color = GameColors.ENEMY_ATTACK
	
	# Create the attack description
	var attack_description: String = "%s attacks %s" % [entity.get_entity_name(), target.get_entity_name()]
	# If damage is greater than 0, append the damage to the description and reduce the target's HP
	if damage > 0:
		attack_description += " for %d hit points." % damage
		MessageLog.send_message(attack_description, attack_color)
		target.fighter_component.hp -= damage
	else:
		# If no damage is dealt, append a no damage message
		attack_description += " but does no damage."
		MessageLog.send_message(attack_description, attack_color)
	
	# Set the action cooldown
	entity.fighter_component.action_cooldown = 2
	entity.fighter_component.attack_animation(offset)
	return true
