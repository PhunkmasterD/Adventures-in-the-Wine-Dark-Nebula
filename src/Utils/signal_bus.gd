extends Node

#player signals
signal player_died
signal player_descended
signal tile_explored(Tile)
signal map_changed(width, height)
signal return_to_overworld

#input signals
signal main_game_input
signal overworld_input

#control signals
signal message_sent(text, color)
signal escape_requested
signal zoom_changed(reset: bool, factor: float)

#orphan node signals
signal clear_orphan_nodes()
