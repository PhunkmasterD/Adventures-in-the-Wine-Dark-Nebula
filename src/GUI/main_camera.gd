extends Camera2D

const DEFAULT_ZOOM = 2
const MIN_ZOOM = 1.0
const MAX_ZOOM = 3.0

# Ready function to connect signals
func _ready() -> void:
	# Connect the map_changed signal to update camera limits
	SignalBus.map_changed.connect(_on_map_changed)
	# Connect the zoom_changed signal to update camera zoom
	SignalBus.zoom_changed.connect(_on_zoom_changed)
	SignalBus.clear_orphan_nodes.connect(_on_clear_orphan_nodes)

# Function to update camera limits when the map changes
func _on_map_changed(width: int, height: int) -> void:
	# Set the camera limits based on the map dimensions
	self.limit_left = 0
	self.limit_right = width * 16
	self.limit_top = 0
	self.limit_bottom = height * 16

# Function to update camera zoom
func _on_zoom_changed(reset: bool, factor: float) -> void:
	print(zoom.x)
	print(zoom.y)
	# Reset the zoom to the default value if reset is true
	if reset:
		self.zoom = Vector2(DEFAULT_ZOOM, DEFAULT_ZOOM)
		return
	# Calculate the target zoom based on the current zoom and the factor
	var target_zoom = self.zoom.x + factor
	# Clamp the target zoom to the minimum and maximum zoom values
	target_zoom = clamp(target_zoom, MIN_ZOOM, MAX_ZOOM)
	# Set the camera zoom to the target zoom
	self.zoom = Vector2(target_zoom, target_zoom)

func _on_clear_orphan_nodes():
	if self.get_parent() == null:
		queue_free()