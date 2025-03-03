extends MarginContainer

@onready var hp_bar: ProgressBar = $"%HpBar"
@onready var hp_label: Label = $"%HpLabel"

# Function to initialize the HP display with the player entity
func initialize(player: Entity) -> void:
	# Wait until the node is fully initialized
	if not is_inside_tree():
		await ready
	# Connect the player's HP changed signal to update the display
	player.fighter_component.hp_changed.connect(player_hp_changed)
	# Get the player's current and maximum HP
	var player_hp: int = player.fighter_component.hp
	var player_max_hp: int = player.fighter_component.max_hp
	# Update the HP display with the player's current HP
	player_hp_changed(player_hp, player_max_hp)

# Function to update the HP display when the player's HP changes
func player_hp_changed(hp: int, max_hp: int) -> void:
	# Update the HP bar's maximum value and current value
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	# Update the HP label text
	hp_label.text = "HP: %d/%d" % [hp, max_hp]
