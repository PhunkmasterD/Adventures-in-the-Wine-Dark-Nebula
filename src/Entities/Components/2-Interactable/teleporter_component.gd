class_name TeleporterComponent
extends InteractableComponent

# Variable to store information about the encoded text
var teleport_coordinates: Vector3i

# Initialize the component with the definition data
func _init(definition: TeleporterComponentDefinition) -> void:
    teleport_coordinates = definition.teleport_coordinates  

# Now we go to the location stored in the entity
func activate(action: InteractAction) -> bool:
    var tile = action.entity.map_data.get_tile(action.entity.grid_position)
   #SignalBus.tile_explored.emit(tile) # This whole system needs to be updated so that it just sends the player to a given coordinates
   #Will need to update the whole map system to assign sets of maps to planets categorized by: Planet, Location, Stratum
   #Just to confirm it work:
    MessageLog.add_message("Teleporting to: " + str(teleport_coordinates))
    return false