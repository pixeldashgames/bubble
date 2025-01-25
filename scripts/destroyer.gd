extends CharacterBody3D

@export var movement_speed: float = 4.0
@export var follow_target: Node3D
@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")

var enabled = true

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func set_movement_target(movement_target: Vector3):
	if not enabled:
		return
	
	navigation_agent.set_target_position(movement_target)

func _process(_delta: float) -> void:
	if not enabled:
		return
	
	set_movement_target(follow_target.global_position)

func _physics_process(_delta):
	if not enabled:
		return
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	
	if not velocity.is_zero_approx():
		look_at(global_position + velocity)
		
	move_and_slide()


func _on_health_death() -> void:
	enabled = false
	queue_free()
