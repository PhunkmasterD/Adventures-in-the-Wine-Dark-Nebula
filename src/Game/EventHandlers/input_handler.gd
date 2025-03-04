class_name InputHandler
extends Node

enum InputHandlers {MAIN_GAME, OVERWORLD, GAME_OVER, HISTORY_VIEWER, DUMMY, MACRO}

@export var start_input_handler: InputHandlers

@onready var input_handler_nodes := {
	InputHandlers.MAIN_GAME: $MainGameInputHandler,
	InputHandlers.OVERWORLD: $OverworldInputHandler,
	InputHandlers.GAME_OVER: $GameOverInputHandler,
	InputHandlers.HISTORY_VIEWER: $HistoryViewerInputHandler,
	InputHandlers.DUMMY: $DummyInputHandler,
	InputHandlers.MACRO: $MacroInputHandler,
}

var current_input_handler: BaseInputHandler
var current_input_node: InputHandlers
var previous_input_node: InputHandlers


func _ready() -> void:
	transition_to(start_input_handler)
	SignalBus.player_died.connect(transition_to.bind(InputHandlers.GAME_OVER))
	SignalBus.main_game_input.connect(transition_to.bind(InputHandlers.MAIN_GAME))
	SignalBus.overworld_input.connect(transition_to.bind(InputHandlers.OVERWORLD))


func get_action(player: Entity) -> Action:
	return await current_input_handler.get_action(player)


func transition_to(input_handler: InputHandlers) -> void:
	previous_input_node = current_input_node
	if current_input_handler != null:
		current_input_handler.exit()
	current_input_handler = input_handler_nodes[input_handler]
	current_input_node = input_handler
	current_input_handler.enter()

func transition_to_previous() -> void:
	transition_to(previous_input_node)
