class_name FieldOfView
extends Node

# Multipliers for field of view calculation
const multipliers = [
	[1, 0, 0, -1, -1, 0, 0, 1],
	[0, 1, -1, 0, 0, -1, 1, 0],
	[0, 1, 1, 0, 0, -1, -1, 0],
	[1, 0, 0, 1, -1, 0, 0, -1]
]

# Array to store tiles in field of view
var _fov: Array[Tile] = []

# Function to update the field of view
func update_fov(map_data: MapData, origin: Vector2i, radius: int) -> void:
	# Clear the current field of view
	_clear_fov()
	# Get the starting tile and mark it as in view
	var start_tile: Tile = map_data.get_tile(origin)
	start_tile.is_in_view = true
	_fov = [start_tile]
	# Cast light in all 8 directions
	for i in 8:
		_cast_light(map_data, origin.x, origin.y, radius, 1, 1.0, 0.0, multipliers[0][i], multipliers[1][i], multipliers[2][i], multipliers[3][i])

# Function to reset the field of view
func reset_fov() -> void:
	_fov = []

# Function to clear the field of view
func _clear_fov() -> void:
	# Mark all tiles in the current field of view as not in view
	for tile in _fov:
		tile.is_in_view = false
	_fov = []

# Function to cast light for field of view calculation
func _cast_light(map_data: MapData, x: int, y: int, radius: int, row: int, start_slope: float, end_slope: float, xx: int, xy: int, yx: int, yy: int) -> void:
	# Stop if the start slope is less than the end slope
	if start_slope < end_slope:
		return
	var next_start_slope: float = start_slope
	# Iterate over each row within the radius
	for i in range(row, radius + 1):
		var blocked: bool = false
		var dy: int = -i
		# Iterate over each column in the row
		for dx in range(-i, 1):
			var l_slope: float = (dx - 0.5) / (dy + 0.5)
			var r_slope: float = (dx + 0.5) / (dy - 0.5)
			# Skip if the start slope is less than the right slope
			if start_slope < r_slope:
				continue
			# Break if the end slope is greater than the left slope
			elif end_slope > l_slope:
				break
			var sax: int = dx * xx + dy * xy
			var say: int = dx * yx + dy * yy
			# Skip if the coordinates are out of bounds
			if ((sax < 0 and absi(sax) > x) or (say < 0 and absi(say) > y)):
				continue
			var ax: int = x + sax
			var ay: int = y + say
			if ax >= map_data.width or ay >= map_data.height:
				continue
			var radius2: int = radius * radius
			var current_tile: Tile = map_data.get_tile_xy(ax, ay)
			# Mark the tile as in view if it is within the radius
			if (dx * dx + dy * dy) < radius2:
				current_tile.is_in_view = true
				_fov.append(current_tile)
			# Handle blocked tiles
			if blocked:
				if not current_tile.is_transparent():
					next_start_slope = r_slope
					continue
				else:
					blocked = false
					start_slope = next_start_slope
			elif not current_tile.is_transparent():
				blocked = true
				next_start_slope = r_slope
				_cast_light(map_data, x, y, radius, i + 1, start_slope, l_slope, xx, xy, yx, yy)
		if blocked:
			break
