extends HBoxContainer

var _player: Entity

@onready var level_label: Label = $LevelLabel
@onready var attack_label: Label = $AttackLabel
@onready var defense_label: Label = $DefenseLabel

# Function to set up the character info box with the player entity
func setup(player: Entity) -> void:
	_player = player
	# Connect signals for level up and equipment change to update labels
	_player.level_component.leveled_up.connect(update_labels)
	_player.equipment_component.equipment_changed.connect(update_labels)
	# Update the labels initially
	update_labels()

# Function to update the labels with the player's current stats
func update_labels() -> void:
	# Wait until the player is fully initialized
	if not _player.is_inside_tree():
		await _player.ready
	# Update the level label
	level_label.text = "LVL: %d" % _player.level_component.current_level
	# Update the attack label
	attack_label.text = "ATK: %d" % _player.fighter_component.power
	# Update the defense label
	defense_label.text = "DEF: %d" % _player.fighter_component.defense
