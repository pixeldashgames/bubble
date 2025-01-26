class_name Teleporter extends Node

@export var interactable: Interactable
@export var player_movement: PlayerMovement
@export var player_pov: PlayerPOV
@export var target_pos: Node3D

@export var target_pov_distance: float
@export var target_pov_height: float
@export var target_pov_angle: float
@export var target_background_music: AudioStream
@export var interact_sound: AudioStreamPlayer3D
@export var allow_combat_music := false

func _ready() -> void:
	interactable.interact.connect(on_interact)
	interactable.disable_interaction_system_on_interaction = true
	interactable.disable_player_on_interaction = true

func on_interact(action: int):
	if action != 0:
		return
	
	GameController.Instance.allow_combat_music = allow_combat_music
	GameController.Instance.change_background_music(target_background_music)
	interact_sound.play()
	
	await player_movement.teleport_to(target_pos.global_position)
	
	player_pov.reset_pov(target_pov_distance, target_pov_height, target_pov_angle)
	
	InteractionSystem.Instance.finish_interaction()
