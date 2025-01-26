class_name Enemy extends CharacterBody3D

@export var attack_damage: float
@export var attack_interval: float
@export var target_teams: Array[String]
@export var team_priorities: Array[int]
@export var avoidance_distance_range: Vector2
@export var movement_speed: float = 4.0

@export var death_animation_name: String
@export var idle_animation_name: String
@export var attack_animation_name: String
@export var move_animation_name: String

@export var animation_player: AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")

var current_target: Health = null
var targets: Array[Health] = []

var last_attack_time := 0

var enabled = true
var moving = false

var general_objective: Health = null

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	navigation_agent.radius = randf_range(avoidance_distance_range.x, avoidance_distance_range.y)

func set_movement_target(movement_target: Vector3):
	if not enabled:
		return
	
	navigation_agent.set_target_position(movement_target)

func check_targets() -> void:
	var closest_target_distance := 9999.9
	var highest_priority_target := -9999
	current_target = null
	
	var remove_indexes: Array[int] = []
	
	for i in targets.size():
		var target := targets[i]
		if target == null or not is_instance_valid(target) or target.is_dead:
			remove_indexes.append(i)
			continue
		
		var distance = (global_position - target.global_position).length_squared()
		var team_index := target_teams.find(target.team)
		
		var priority = team_priorities[team_index]
		if priority > highest_priority_target:
			highest_priority_target = priority
			closest_target_distance = distance
			current_target = target
		elif priority == highest_priority_target and distance < closest_target_distance:
			closest_target_distance = distance
			current_target = target
	
	var removed := 0
	for index in remove_indexes:
		targets.remove_at(index - removed)
		removed += 1

func set_general_objective(objective: Health):
	general_objective = objective

func _process(_delta: float) -> void:
	if not enabled:
		return
		
	check_targets()
	
	var target = current_target
	if target == null:
		target = general_objective
	
	if target == null:
		return
		
	set_movement_target(target.global_position)
	
	if moving:
		return
	
	var time = Time.get_ticks_msec()
	
	if time - last_attack_time < attack_interval:
		return
	
	last_attack_time = time
	
	target.damage(attack_damage)
	
	animation_player.play(attack_animation_name)
	

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
	if not enabled:
		return
		
	velocity = safe_velocity
	
	var look_at_target = Vector3(velocity.x, 0, velocity.z)
	
	if look_at_target.length() > 0.1:
		look_at(global_position + look_at_target)
		if not moving:
			moving = true
			animation_player.play(move_animation_name)
	else:
		var target = current_target
		if current_target == null:
			target = general_objective
		if target != null:
			var pos = target.global_position
			pos.y = global_position.y
			look_at(pos)
		
		if moving:
			moving = false
			animation_player.play(idle_animation_name)
		
	move_and_slide()

func _on_health_death() -> void:
	enabled = false
	velocity = Vector3.ZERO
	animation_player.play(death_animation_name)
	GameController.Instance.on_enemy_killed()

func _on_enemy_aggro_body_entered(body: Node3D) -> void:
	var health_node: Health = body.get_node_or_null("Health")
	
	if health_node == null or health_node.is_dead or not target_teams.has(health_node.team):
		return
	
	targets.append(health_node)

func _on_enemy_aggro_body_exited(body: Node3D) -> void:
	var health_node = body.get_node_or_null("Health")
	
	if health_node == null or health_node.is_dead or not target_teams.has(health_node.team):
		return

	if targets.has(health_node):
		targets.erase(health_node)
