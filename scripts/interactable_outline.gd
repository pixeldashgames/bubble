class_name InteractableOutline extends Node

@export var interactable: Interactable
@export var mesh: MeshInstance3D
@export var outline_material: Material

func _ready() -> void:
	mesh.material_override = mesh.mesh.surface_get_material(0).duplicate()
	interactable.select.connect(on_select)
	interactable.deselect.connect(on_deselect)

func on_select():
	mesh.material_override.next_pass = outline_material

func on_deselect():
	mesh.material_override.next_pass = null
