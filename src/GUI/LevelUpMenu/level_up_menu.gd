class_name LevelUpMenu
extends CanvasLayer

# Signal emitted when the level-up process is completed
signal level_up_completed

# Reference to the player entity
var player: Entity

# References to the upgrade buttons in the UI
@onready var health_upgrade_button: Button = $"%HealthUpgradeButton"
@onready var power_upgrade_button: Button = $"%PowerUpgradeButton"
@onready var defense_upgrade_button: Button = $"%DefenseUpgradeButton"

# Setup function to initialize the level-up menu with the player's current stats
func setup(player: Entity) -> void:
	self.player = player
	var fighter: FighterComponent = player.fighter_component
	# Set the button texts to show the current stats and the upgrade options
	health_upgrade_button.text = "(a) Constitution (+20 HP, from %d)" % fighter.max_hp
	power_upgrade_button.text = "(b) Strength (+1 attack, from %d)" % fighter.power
	defense_upgrade_button.text = "(c) Agility (+1 defense, from %d)" % fighter.defense
	# Set focus to the health upgrade button by default
	health_upgrade_button.grab_focus()

# Function called when the health upgrade button is pressed
func _on_health_upgrade_button_pressed() -> void:
	player.level_component.increase_max_hp()
	queue_free()
	# Emit the level_up_completed signal
	level_up_completed.emit()

# Function called when the power upgrade button is pressed
func _on_power_upgrade_button_pressed() -> void:
	player.level_component.increase_power()
	queue_free()
	# Emit the level_up_completed signal
	level_up_completed.emit()

# Function called when the defense upgrade button is pressed
func _on_defense_upgrade_button_pressed() -> void:
	player.level_component.increase_defense()
	queue_free()
	# Emit the level_up_completed signal
	level_up_completed.emit()
