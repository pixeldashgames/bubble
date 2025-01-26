class_name PlayerPOV extends Node3D

@export var player: Node3D
@export var follow_speed: float
@export var camera: Node3D
@export var player_distance: float
@export var height: float
@export var angle: float

var offset: Vector3

func _ready() -> void:
	reset_pov(player_distance, height, angle)


func _process(delta: float) -> void:
	global_position = global_position.lerp(player.global_position + offset, delta * follow_speed)
	

func reset_pov(distance: float, height: float, angle: float) -> void:
	var dir = Vector3(cos(deg_to_rad(angle)), 0, sin(deg_to_rad(angle)))
	offset = dir * distance + Vector3.UP * height
	
	global_position = player.global_position + offset
	
	var look_offset = Vector3(player.global_position.x, global_position.y, player.global_position.z)
	
	look_at(look_offset)
	
	camera.look_at(player.global_position)	
