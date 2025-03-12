class_name BumpAction
extends ActionWithDirection

# Sorts based an action with direction into a melee or movement action depending on if there is an actor.
func perform() -> bool:
	if get_target_actor():
		return MeleeAction.new(entity, offset.x, offset.y).perform()
	if get_target_interactable():
		return InteractAction.new(entity, get_target_interactable()).perform()
	else:
		return MovementAction.new(entity, offset.x, offset.y).perform()
