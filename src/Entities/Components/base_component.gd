class_name Component
extends Node

# Get the parent entity
@onready var entity: Entity = get_parent() as Entity

func _init() -> void:
	SignalBus.clear_orphan_nodes.connect(_on_clear_orphan_nodes)

func _on_clear_orphan_nodes():
	if self.get_parent() == null:
		queue_free()

# Get the map data associated with the entity
func get_map_data() -> MapData:
	return entity.map_data
