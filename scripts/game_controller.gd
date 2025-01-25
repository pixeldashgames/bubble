extends Node3D

@export var input_mapping_context: GUIDEMappingContext

func _ready() -> void:
	GUIDE.enable_mapping_context(input_mapping_context)
