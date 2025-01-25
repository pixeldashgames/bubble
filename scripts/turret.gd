extends Node3D

@export var fire_rate: float
@export var damage: float
@export var tracking_time: float
@export var turret_head: Node3D
@export var turret_health: Health
@export var enabled := true

var targets: Array[Health]
var current_target: Health = null

var last_attack_time: float = -10000
var started_tracking_time: float = -10000

func check_nearest_target():		
	var closest_target_squared: float = 10000000
	var last_target := current_target
	current_target = null
	
	var remove_indexes: Array[int] = []
	for i in targets.size():
		var target := targets[i]
		if targets[i] == null or not is_instance_valid(targets[i]) or target.is_dead:
			remove_indexes.append(i)
			continue
		
		var distance_sqr := (target.global_position - global_position).length_squared()
		
		if distance_sqr < closest_target_squared:
			closest_target_squared = distance_sqr
			current_target = target
	for index in remove_indexes:
		targets.remove_at(index)
	
	if last_target != current_target and current_target != null:
		started_tracking_time = Time.get_ticks_msec()

func _process(_delta: float) -> void:
	if not enabled:
		return
		
	if current_target == null or not is_instance_valid(current_target) or current_target.is_dead:
		check_nearest_target()
	
	if current_target == null:
		return
	
	var time := Time.get_ticks_msec()
	
	var target_forward = current_target.global_position - turret_head.global_position
	target_forward.y = 0
	target_forward = target_forward.normalized()
	
	var elapsed := time - started_tracking_time
	if elapsed < tracking_time:
		var current_forward = -turret_head.global_basis.z
		
		var slerped = current_forward.slerp(target_forward, elapsed / tracking_time)
		
		turret_head.look_at(turret_head.global_position + slerped)
		return
	
	turret_head.look_at(turret_head.global_position + target_forward)
	
	if time - last_attack_time >= fire_rate:
		last_attack_time = time
		
		current_target.damage(damage)


func _on_turret_aggro_body_entered(body: Node3D) -> void:
	var health_node: Health = body.get_node_or_null("Health")
	
	if health_node == null or health_node.is_dead or health_node.team == turret_health.team:
		return
	
	targets.append(health_node)


func _on_turret_aggro_body_exited(body: Node3D) -> void:
	var health_node = body.get_node_or_null("Health")
	
	if health_node == null or health_node.is_dead or health_node.team == turret_health.team:
		return

	if targets.has(health_node):
		targets.erase(health_node)
