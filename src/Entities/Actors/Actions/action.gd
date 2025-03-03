class_name Action
extends RefCounted

var entity: Entity
var cooldown: float

func _init(entity: Entity) -> void:
	self.entity = entity
	self.cooldown = 0


func perform() -> bool:
	return false


func get_map_data() -> MapData:
	return entity.map_data
