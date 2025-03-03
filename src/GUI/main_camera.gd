extends Camera2D

const DEFAULT_ZOOM = 2
const MIN_ZOOM = 1.0
const MAX_ZOOM = 3.0

func _ready() -> void:
	SignalBus.map_changed.connect(_on_map_changed)
	SignalBus.zoom_changed.connect(_on_zoom_changed)

func _on_map_changed(width: int, height: int) -> void:
	self.limit_left = 0
	self.limit_right = width * 16
	self.limit_top = 0
	self.limit_bottom = height * 16

func _on_zoom_changed(reset: bool, factor: float) -> void:
	print(zoom.x)
	print(zoom.y)
	if reset:
		self.zoom = Vector2(DEFAULT_ZOOM, DEFAULT_ZOOM)
		return
	var target_zoom = self.zoom.x + factor
	target_zoom = clamp(target_zoom, MIN_ZOOM, MAX_ZOOM)
	self.zoom = Vector2(target_zoom, target_zoom)