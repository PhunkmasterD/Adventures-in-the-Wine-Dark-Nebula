extends BaseInputHandler

var turns: int
var max_turns: int

func enter() -> void:
    turns = 0
    max_turns = 10

func exit() -> void:
    pass

func get_action(player: Entity) -> Action:
    var action: Action = null
    var offset: Vector2i = Vector2i.UP
    action = BumpAction.new(player, offset.x, offset.y)
    turns += 1
    if turns >= max_turns:
        get_parent().transition_to_previous()
    return action

