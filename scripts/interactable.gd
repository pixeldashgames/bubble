class_name Interactable extends CollisionObject3D

signal interact(input_index: int)
signal select
signal deselect

@export var interactable_name: String
@export var input_names: Array[String]

@export var interactable_priority: int = 0
@export var disable_player_on_interaction: bool = false
@export var can_interact: bool = true

func on_interact(input_index: int):
	interact.emit(input_index)

func on_select():
	select.emit()

func on_deselect():
	deselect.emit()
