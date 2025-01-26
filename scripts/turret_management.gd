extends Node

@export var scrap_resource: GameResource
@export var turret_interactable: Interactable
@export var turret_long_interactable: LongInteractable
@export var turret_health: Health
@export var turret: Turret
@export var build_cost: int
@export var upgrade_costs: Array[int]
@export var fire_rates: Array[float]
@export var damages: Array[float]
@export var tracking_times: Array[float]
@export var healths: Array[float]
@export var animation_tree: AnimationTree
@export var upgrade_players: Array[AnimationPlayer]
@export var upgrade_turret_meshes: Array[Node3D]
@export var upgrade_turret_heads: Array[Node3D]
@export var beam_spawn_points: Array[Node3D]

@export var interactable_name: String
@export var upgrade_action_name: String
@export var repair_action_name: String
@export var upgrade_interactable_name: String
@export var repair_interactable_name: String
@export var upgrade_cancel_name: String
@export var repair_cancel_name: String
@export var upgrade_time: float
@export var repair_time: float

@export var repair_fraction: float

@export var turret_repaired_notif: AudioStream
@export var turret_created_notif: AudioStream
@export var turret_destroyed_notif: AudioStream

var current_level = -1
var upgrading = false

func _ready() -> void:
	turret_interactable.input_names = [turret_interactable.input_names[0] + " (x%d[img=32]%s[/img])" % [build_cost, scrap_resource.icon.resource_path]]

func _process(_delta: float) -> void:
	if current_level >= 0:
		turret_interactable.info_details = get_turret_info()
	
	if upgrading or turret_long_interactable.running:
		return
	
	var scrap := PlayerInventory.Instance.get_resource_amount(scrap_resource)
	
	if current_level < 0:
		turret_interactable.interactions_enabled[0] = scrap >= build_cost
	elif current_level < fire_rates.size():
		turret_interactable.interactions_enabled[0] = scrap >= upgrade_costs[current_level] and not turret_health.is_dead
		turret_interactable.interactions_enabled[1] = turret_health.health < turret_health.max_health
	else:
		turret_interactable.interactions_enabled[0] = turret_health.health < turret_health.max_health


func get_turret_info() -> String:
	var string = "Salud    %d/%d\n" % [turret_health.health, turret_health.max_health]
	
	string +=   "\nDaño          %d" % roundi(turret.damage)
	if current_level < fire_rates.size():
		var value := roundi(damages[current_level])
		if value != roundi(turret.damage):
			string += "  →   [color=green]%d[/color]" % value
			
	string +=   "\nCadencia      %.1f" % (1000.0 / turret.fire_rate)
	if current_level < fire_rates.size():
		var value = 1000.0 / fire_rates[current_level]
		if not is_equal_approx(value, 1000.0 / turret.fire_rate):
			string += "  →   [color=green]%d[/color]" % value
	
	string +=   "\nRetraso       %d" % roundi(turret.tracking_time)
	if current_level < fire_rates.size():
		var value = roundi(tracking_times[current_level])
		if not is_equal_approx(value, roundi(turret.tracking_time)):
			string += "  →   [color=green]%d[/color]" % value
	
	string +=   "\nSalud Máx.    %d" % roundi(turret_health.max_health)
	if current_level < fire_rates.size():
		var value = roundi(healths[current_level])
		if not is_equal_approx(value, roundi(turret_health.max_health)):
			string += "  →   [color=green]%d[/color]" % value
	return string

func _on_long_interactable_long_interact(action_index: int) -> void:
	if action_index == 0:
		upgrading = true
		if current_level < 0:
			PlayerInventory.Instance.extract_resource(scrap_resource, build_cost)
			
			AIAssistantVoice.Instance.enqueue_notif(turret_created_notif)
			
			animation_tree.set("parameters/conditions/build", true)
			turret_interactable.can_interact = false
			
			await animation_tree.animation_finished
			
			turret_health.enabled = true
			
			animation_tree.set("parameters/conditions/build", false)
			
			turret_interactable.interactable_name = interactable_name + " Lv. 1"
			turret_interactable.info_title = turret_interactable.interactable_name
			turret_interactable.interactions_enabled = [false, false] as Array[bool]
			turret_interactable.input_names = [upgrade_action_name + " (x%d[img=32]%s[/img])" % [upgrade_costs[0], scrap_resource.icon.resource_path], repair_action_name]
			
			turret_interactable.can_interact = true
			turret.enabled = true
			
			turret_long_interactable.cancel_input_names = [upgrade_cancel_name, repair_cancel_name]
			turret_long_interactable.interaction_times = [upgrade_time, repair_time]
			turret_long_interactable.interaction_names = [upgrade_interactable_name, repair_interactable_name]
			turret_long_interactable.intercept_actions = [true, true] as Array[bool]
			
			turret_interactable.info_details = get_turret_info()
			current_level = 0
		elif current_level < fire_rates.size():
			PlayerInventory.Instance.extract_resource(scrap_resource, build_cost)
			
			turret_interactable.can_interact = false
			turret.enabled = false
			turret_health.enabled = false
			
			animation_tree.set("parameters/conditions/upgrade", true)
			
			await animation_tree.animation_finished
			
			animation_tree.set("parameters/conditions/upgrade", false)
			
			upgrade_turret_meshes[current_level].hide()
			upgrade_turret_meshes[current_level + 1].show()
			turret.turret_head = upgrade_turret_heads[current_level]
			turret.beams_spawn_point = beam_spawn_points[current_level]
			
			animation_tree.anim_player = upgrade_players[current_level].get_path()
			
			animation_tree.set("parameters/conditions/build", true)

			await animation_tree.animation_finished
			
			animation_tree.set("parameters/conditions/build", false)
			
			if current_level + 1 == fire_rates.size():
				turret_interactable.interactable_name = interactable_name + " Lv. MAX"
				
			else:
				turret_interactable.interactable_name = interactable_name + " Lv. " + str(current_level + 2)
			turret_interactable.info_title = turret_interactable.interactable_name
			
			turret.upgrade(fire_rates[current_level], damages[current_level], tracking_times[current_level])
			var new_health := healths[current_level]
			var new_current_health = new_health * (turret_health.health / turret_health.max_health)
			turret_health.max_health = new_health
			turret_health.health = new_current_health
			current_level += 1
			
			if current_level == fire_rates.size():
				turret_interactable.interactions_enabled = [false] as Array[bool]
				turret_interactable.input_names = [repair_action_name]
				turret_long_interactable.cancel_input_names = [repair_cancel_name]
				turret_long_interactable.interaction_times = [repair_time]
				turret_long_interactable.interaction_names = [repair_interactable_name]
				turret_long_interactable.intercept_actions = [true] as Array[bool]
			else:
				turret_interactable.input_names[0] = upgrade_action_name + " (x%d[img=32]%s[/img])" % [upgrade_costs[current_level], scrap_resource.icon.resource_path] 
			turret_interactable.can_interact = true
			turret.enabled = true
			turret_health.enabled = true
			
			turret_interactable.info_details = get_turret_info()
		else:
			turret_health.heal(turret_health.max_health * repair_fraction)
		upgrading = false
	elif action_index == 1:
		turret_health.heal(turret_health.max_health * repair_fraction)


func _on_health_death() -> void:
	turret.enabled = false
	AIAssistantVoice.Instance.enqueue_notif(turret_destroyed_notif)
	
	animation_tree.set("parameters/conditions/upgrade", true)

	await animation_tree.animation_finished
	
	animation_tree.set("parameters/conditions/upgrade", false)
	

func _on_health_revive() -> void:
	AIAssistantVoice.Instance.enqueue_notif(turret_repaired_notif)
	
	turret_health.enabled = false
	
	animation_tree.set("parameters/conditions/build", true)

	await animation_tree.animation_finished
	
	animation_tree.set("parameters/conditions/build", false)
	
	turret_health.enabled = true
	turret.enabled = true	
