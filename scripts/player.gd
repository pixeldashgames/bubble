class_name PlayerMovement extends CharacterBody3D

@export var player_pov: Node3D
@export var move_speed: float
@export var max_speed_delta: float
@export var player_movement_input: GUIDEAction
@export var enabled := true

var target_movement: Vector3 = Vector3()
var current_movement: Vector3 = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_handle_user_input()
	_handle_movement(delta)

func _handle_movement(delta: float) -> void:
	current_movement = current_movement.lerp(target_movement, max_speed_delta * delta)
	velocity = current_movement
	velocity += get_gravity() * delta
	move_and_slide()

func _handle_user_input() -> void:
	if not enabled:
		target_movement = Vector3.ZERO
		return
		
	var input: Vector2 = player_movement_input.value_axis_2d
	
	var movement = player_pov.to_global(Vector3(input.x, 0, input.y)) - player_pov.global_position
	
	target_movement = movement * move_speed
