extends Node3D

@export var player: Node3D
@export var offset: Vector3
@export var follow_speed: float

func _process(delta: float) -> void:
	global_position = global_position.lerp(player.global_position + offset, delta * follow_speed)
	
