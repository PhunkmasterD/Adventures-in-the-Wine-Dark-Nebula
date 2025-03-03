class_name ExploreTileAction
extends Action

# Declare variables for the tile location and tile
var tile_location: Vector2i
var tile: Tile

# Initialize the ExploreTileAction with an entity, tile location, and tile
func _init(entity: Entity, tile_location: Vector2i, tile: Tile):
	# Call the parent class initializer
	super._init(entity)
	self.tile_location = tile_location
	self.tile = tile

# Perform the explore tile action, returns true if successful
func perform() -> bool:
	var message = "You explore the %s" % tile.tile_name
	MessageLog.send_message(message, GameColors.DESCEND)
	# Check if the tile is an overworld tile
	if tile.is_overworld():
		SignalBus.tile_explored.emit(tile)
		SignalBus.main_game_input.emit()
		return true
	else:
		MessageLog.send_message("You don't see anything of interest here", GameColors.IMPOSSIBLE)
	return false
