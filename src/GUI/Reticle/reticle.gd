class_name Reticle
extends Node2D

signal position_selected(grid_position)

const directions = {
	"move_up": Vector2i.UP,
	"move_down": Vector2i.DOWN,
	"move_left": Vector2i.LEFT,
	"move_right": Vector2i.RIGHT,
	"move_up_left": Vector2i.UP + Vector2i.LEFT,
	"move_up_right": Vector2i.UP + Vector2i.RIGHT,
	"move_down_left": Vector2i.DOWN + Vector2i.LEFT,
	"move_down_right": Vector2i.DOWN + Vector2i.RIGHT,
}

var grid_position: Vector2i:
	set(value):
		grid_position = value
		position = Grid.grid_to_world(grid_position)

var map_data: MapData

@onready var camera: Camera2D = $Camera2D
@onready var border: Line2D = $Line2D

# Called when the node is added to the scene.
func _ready() -> void:
	hide()
	set_physics_process(false)

# Function to select a position within a given radius around the player.
func select_position(player: Entity, radius: int) -> Vector2i:
	# Store the map data and initial grid position from the player.
	map_data = player.map_data
	grid_position = player.grid_position
	
	# Get the current camera and switch to the reticle's camera.
	var player_camera: Camera2D = get_viewport().get_camera_2d()
	camera.make_current()
	
	# Set up the border around the reticle based on the radius.
	_setup_border(radius)
	
	# Show the reticle and wait for the next physics frame.
	show()
	await get_tree().physics_frame
	
	# Enable the physics process to handle input.
	set_physics_process.call_deferred(true)
	
	# Wait for the position_selected signal to be emitted and store the selected position.
	var selected_position: Vector2i = await position_selected
	
	# Disable the physics process and switch back to the player's camera.
	set_physics_process(false)
	player_camera.make_current()
	
	# Hide the reticle and return the selected position.
	hide()
	return selected_position

# Called every physics frame to handle input and update the reticle's position.
func _physics_process(delta: float) -> void:
	var offset := Vector2i.ZERO
	
	# Check for directional input and update the offset accordingly.
	for direction in directions:
		if Input.is_action_just_pressed(direction):
			offset += directions[direction]
	
	# Update the grid position based on the offset.
	grid_position += offset
	
	# Emit the position_selected signal if the accept or back action is pressed.
	if Input.is_action_just_pressed("ui_accept"):
		position_selected.emit(grid_position)
	if Input.is_action_just_pressed("ui_back"):
		position_selected.emit(Vector2i(-1, -1))

# Sets up the border around the reticle based on the given radius.
func _setup_border(radius: int) -> void:
	if radius <= 0:
		# Hide the border if the radius is zero or negative.
		border.hide()
	else:
		# Calculate the border points based on the radius and tile size.
		border.points = [
			Vector2i(-radius, -radius) * Grid.tile_size,
			Vector2i(-radius, radius + 1) * Grid.tile_size,
			Vector2i(radius + 1, radius + 1) * Grid.tile_size,
			Vector2i(radius + 1, -radius) * Grid.tile_size,
			Vector2i(-radius, -radius) * Grid.tile_size
		]
		# Show the border.
		border.show()
