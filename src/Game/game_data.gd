class_name GameData
extends Node

# Function to save player data to a separate file
func save_player(player: Entity) -> void:
	print("Saving player data...")
	var player_data = player.get_save_data()
	var file = FileAccess.open("user://save_data/player_data.dat", FileAccess.WRITE)
	var save_string: String = JSON.stringify(player_data)
	var save_hash: String = save_string.sha256_text()
	file.store_line(save_hash)
	file.store_line(save_string)
	print("Player data saved to file")

# Function to load player data from a separate file
func load_player(player: Entity) -> void:
	print("Loading player data...")
	var file = FileAccess.open("user://save_data/player_data.dat", FileAccess.READ)
	var retrieved_hash: String = file.get_line()
	var save_string: String = file.get_line()
	var calculated_hash: String = save_string.sha256_text()
	if retrieved_hash != calculated_hash:
		print("Invalid hash, player data corrupted")
		return
	var player_data = JSON.parse_string(save_string)
	if typeof(player_data) == TYPE_DICTIONARY:
		player.restore(player_data)
	print("Player data loaded from file")
