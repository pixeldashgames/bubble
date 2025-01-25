extends MeshInstance3D

@export var turret: Node3D
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var interactable: Interactable = $Interactable

func _on_interactable_interact(_action: int) -> void:
	animation.play("build_turret")
	interactable.can_interact = false
