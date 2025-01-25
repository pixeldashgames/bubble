extends Node

@export var scrap_resource: GameResource
@export var turret_interactable: Interactable
@export var turret_long_interactable: LongInteractable
@export var turret: Turret
@export var build_cost: int
@export var upgrade_costs: Array[int]
@export var fire_rates: Array[float]
@export var damages: Array[float]
@export var tracking_times: Array[float]
@export var healths: Array[float]
@export var animation: AnimationPlayer

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

var current_level = -1
var upgrading = false

func _ready() -> void:
	turret_interactable.input_names = [turret_interactable.input_names[0] + " (x%d[img=32]%s[/img])" % [build_cost, scrap_resource.icon.resource_path]]

func _process(_delta: float) -> void:
	if upgrading or turret_long_interactable.running:
		return
	
	var scrap := PlayerInventory.Instance.get_resource_amount(scrap_resource)
	
	if current_level < 0:
		turret_interactable.interactions_enabled[0] = scrap >= build_cost
		return
	elif current_level < fire_rates.size():
		turret_interactable.interactions_enabled[0] = scrap >= upgrade_costs[current_level]
		turret_interactable.interactions_enabled[1] = turret.turret_health.health < turret.turret_health.max_health
	else:
		turret_interactable.interactions_enabled[0] = turret.turret_health.health < turret.turret_health.max_health


func _on_long_interactable_long_interact(action_index: int) -> void:
	if action_index == 0:
		upgrading = true
		if current_level < 0:
			PlayerInventory.Instance.extract_resource(scrap_resource, build_cost)
			
			animation.play("build_turret")
			turret_interactable.can_interact = false
			await animation.animation_finished
			
			turret_interactable.interactable_name = interactable_name + " Lv. 1"
			turret_interactable.interactions_enabled = [false, false] as Array[bool]
			turret_interactable.input_names = [upgrade_action_name + " (x%d[img=32]%s[/img])" % [upgrade_costs[0], scrap_resource.icon.resource_path], repair_action_name]
			
			turret_interactable.can_interact = true
			
			turret_long_interactable.cancel_input_names = [upgrade_cancel_name, repair_cancel_name]
			turret_long_interactable.interaction_times = [upgrade_time, repair_time]
			turret_long_interactable.interaction_names = [upgrade_interactable_name, repair_interactable_name]
			turret_long_interactable.intercept_actions = [true, true] as Array[bool]
			current_level = 0
		elif current_level < fire_rates.size():
			PlayerInventory.Instance.extract_resource(scrap_resource, build_cost)
			
			animation.play("upgrade_turret")
			turret_interactable.can_interact = false
			await animation.animation_finished
			
			turret_interactable.interactable_name = interactable_name + " Lv. " + str(current_level + 2)
			
			turret.upgrade(fire_rates[current_level], damages[current_level], tracking_times[current_level], healths[current_level])
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
		else:
			turret.turret_health.heal(turret.turret_health.max_health * repair_fraction)
		upgrading = false
	elif action_index == 1:
		turret.turret_health.heal(turret.turret_health.max_health * repair_fraction)
