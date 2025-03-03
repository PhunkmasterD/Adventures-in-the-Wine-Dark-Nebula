class_name ExploreTileAction
extends Action

var tile_location: Vector2i
var tile: Tile

func _init(entity: Entity, tile_location: Vector2i, tile: Tile):
	super._init(entity)
	self.tile_location = tile_location
	self.tile = tile

func perform() -> bool:
	var message = "You explore the %s" % tile.tile_name
	MessageLog.send_message(message, GameColors.DESCEND)
	if tile.is_overworld():
		SignalBus.tile_explored.emit(tile)
		SignalBus.main_game_input.emit()
		return true
	else:
		MessageLog.send_message("You don't see anything of interest here", GameColors.IMPOSSIBLE)
	return false
