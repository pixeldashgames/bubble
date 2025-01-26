class_name Teleporter extends Node

@export var interactable: Interactable
@export var player_movement: PlayerMovement
@export var player_pov: PlayerPOV
@export var target_pos: Node3D

@export var target_pov_offset: Vector3
@export var target_pov_angle: float

func _ready() -> void:
	interactable.interact.connect(on_interact)
	interactable.disable_interaction_system_on_interaction = true
	interactable.disable_player_on_interaction = true

func on_interact(action: int):
	if action != 0:
		return
	
	await player_movement.teleport_to(target_pos.global_position)
	
	player_pov.offset = target_pov_offset
	player_pov.global_rotation_degrees.y = target_pov_angle
	
	InteractionSystem.Instance.finish_interaction()
