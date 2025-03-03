class_name MapDataService
extends Node

var overworld_width: int = MapConfig.world_map_width
var overworld_height: int = MapConfig.world_map_height
var overworld_depth: int = MapConfig.world_map_depth

var maps: Dictionary = {}

func coordinate_to_index(coordinate: Vector3i) -> int:
    return coordinate.x + coordinate.y * overworld_width + coordinate.z * overworld_width * overworld_height

func index_to_coordinates(index: int) -> Vector3i:
    var x = index % overworld_width
    var y = (index / overworld_width) % overworld_height
    var z = index / (overworld_width * overworld_height)
    return Vector3i(x, y, z)

func check_saved_map(map_coordinates: Vector3i) -> bool:
    print("Checking for saved map...")
    var index = coordinate_to_index(map_coordinates)
    print("Checking for saved map at coordinates %s, index %s" % [map_coordinates, index])
    if index in maps:
        print("Map found")
        return true
    print("Map not found")
    return false

func save_map(map_coordinates: Vector3i, map_data: MapData):
    print("Saving map data...")
    var index = coordinate_to_index(map_coordinates)
    print("Saving map at coordinates: %s, index: %s" % [map_coordinates, index])
    maps[index] = map_data.get_save_data()
    _save_to_file()

func load_map(map_coordinates: Vector3i, player: Entity) -> MapData:
    print("Loading map data...")
    var index = coordinate_to_index(map_coordinates)
    print("Loading map at index %s" % index)
    if index in maps:
        print("Map found at index: %s" % index)
        var map_data = MapData.new(map_coordinates, overworld_width, overworld_height, player)
        map_data = map_data.restore(maps[index])
        print("Map restored at index: %s" % index)
        return map_data
    print("Map not found at index: %s" % index)
    return null

func _save_to_file() -> void:
    print("Saving map data to file...")
    var file = FileAccess.open("user://maps_save.dat", FileAccess.WRITE)
    var save_string: String = JSON.stringify(maps)
    var save_hash: String = save_string.sha256_text()
    file.store_line(save_hash)
    file.store_line(save_string)
    print("Map data saved to file")

func _load_from_file() -> void:
    print("Loading map data from file...")
    print("Retrieving Map Data")
    var file = FileAccess.open("user://maps_save.dat", FileAccess.READ)
    var retrieved_hash: String = file.get_line()
    var save_string: String = file.get_line()
    var calculated_hash: String = save_string.sha256_text()
    var valid_hash: bool = retrieved_hash == calculated_hash
    if not valid_hash:
        print("Invalid hash, map data corrupted")
        return
    var loaded_maps = JSON.parse_string(save_string)
    if typeof(loaded_maps) == TYPE_DICTIONARY:
        maps.clear()
        for key in loaded_maps.keys():
            maps[int(key)] = loaded_maps[key]
    print("Map data loaded from file")
