class_name PlayerMovement extends CharacterBody3D

@export var player_pov: Node3D
@export var move_speed: float
@export var max_speed_delta: float
@export var player_movement_input: GUIDEAction
@export var sprint_action: GUIDEAction
@export var enabled := true
@export var sprint_speed : float

@onready var animation_tree: AnimationTree = $AnimationTree

var target_movement: Vector3 = Vector3()
var current_movement: Vector3 = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func teleport_to(pos: Vector3) -> void:
	enabled = false
	await PlayerHUD.Instance.fade_screen()
	velocity = Vector3.ZERO
	target_movement = Vector3.ZERO
	global_position = pos
	await get_tree().create_timer(1).timeout
	PlayerHUD.Instance.unfade_screen()
	enabled = true
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_handle_user_input()
	_handle_movement(delta)
	_handle_animations()

func _handle_movement(delta: float) -> void:
	current_movement = current_movement.lerp(target_movement, max_speed_delta * delta)
	velocity = current_movement
	velocity += get_gravity() * delta
	move_and_slide()
	
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	if horizontal_velocity.length() >= 0.5:
		look_at(global_position + horizontal_velocity)

func _handle_animations() -> void:
	var idle := false
	var walking := false
	var running := false
	
	var horizontal_velocity = Vector2(velocity.x, velocity.z).length()
	
	if horizontal_velocity < 0.5:
		idle = true
	elif horizontal_velocity < lerpf(move_speed, sprint_speed, 0.5):
		walking = true
	else:
		running = true
	
	animation_tree.set("parameters/conditions/idle", idle)
	animation_tree.set("parameters/conditions/walking", walking)
	animation_tree.set("parameters/conditions/running", running)

func _handle_user_input() -> void:
	if not enabled:
		target_movement = Vector3.ZERO
		return
		
	var input: Vector2 = player_movement_input.value_axis_2d
	
	if input.length() > 1:
		input = input.normalized()
	
	var movement = player_pov.to_global(Vector3(input.x, 0, input.y)) - player_pov.global_position
	
	if sprint_action.value_bool:
		target_movement = movement * sprint_speed
	else:
		target_movement = movement * move_speed
