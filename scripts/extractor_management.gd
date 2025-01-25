extends Node

@export var scrap_resource: GameResource
@export var extractor_interactable: Interactable
@export var extractor_long_interactable: LongInteractable
@export var extractor: Extractor
@export var build_cost: int
@export var upgrade_costs: Array[int]
@export var extraction_intervals: Array[float]
@export var extraction_amounts: Array[int]
@export var storages: Array[int]
@export var healths: Array[float]
@export var animation: AnimationPlayer

@export var interactable_name: String
@export var upgrade_action_name: String
@export var repair_action_name: String
@export var collect_action_name: String
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
	extractor_interactable.input_names = [extractor_interactable.input_names[0] + " (x%d[img=32]%s[/img])" % [build_cost, scrap_resource.icon.resource_path]]

func _process(_delta: float) -> void:
	if upgrading or extractor_long_interactable.running:
		return
	
	var scrap := PlayerInventory.Instance.get_resource_amount(scrap_resource)
	
	if current_level < 0:
		extractor_interactable.interactions_enabled[0] = scrap >= build_cost
		return
	elif current_level < extraction_intervals.size():
		extractor_interactable.interactions_enabled[0] = scrap >= upgrade_costs[current_level]
		extractor_interactable.interactions_enabled[1] = extractor.extractor_health.health < extractor.extractor_health.max_health
		extractor_interactable.interactions_enabled[2] = extractor.accumulated_scrap > 0
	else:
		extractor_interactable.interactions_enabled[0] = extractor.extractor_health.health < extractor.extractor_health.max_health
		extractor_interactable.interactions_enabled[1] = extractor.accumulated_scrap > 0


func _on_long_interactable_long_interact(action_index: int) -> void:
	if action_index == 0:
		upgrading = true
		if current_level < 0:
			PlayerInventory.Instance.extract_resource(scrap_resource, build_cost)
			
			animation.play("build_extractor")
			extractor_interactable.can_interact = false
			await animation.animation_finished
			
			extractor_interactable.interactable_name = interactable_name + " Lv. 1"
			extractor_interactable.interactions_enabled = [false, false, false] as Array[bool]
			extractor_interactable.input_names = [upgrade_action_name + " (x%d[img=32]%s[/img])" % [upgrade_costs[0], scrap_resource.icon.resource_path], repair_action_name, collect_action_name]
			
			extractor_interactable.can_interact = true
			
			extractor_long_interactable.cancel_input_names = [upgrade_cancel_name, repair_cancel_name]
			extractor_long_interactable.interaction_times = [upgrade_time, repair_time]
			extractor_long_interactable.interaction_names = [upgrade_interactable_name, repair_interactable_name]
			extractor_long_interactable.intercept_actions = [true, true] as Array[bool]
			current_level = 0
		elif current_level < extraction_intervals.size():
			PlayerInventory.Instance.extract_resource(scrap_resource, build_cost)
			
			animation.play("upgrade_extractor")
			extractor_interactable.can_interact = false
			await animation.animation_finished
			
			extractor_interactable.interactable_name = interactable_name + " Lv. " + str(current_level + 2)
			
			extractor.upgrade(extraction_intervals[current_level], extraction_amounts[current_level], storages[current_level], healths[current_level])
			current_level += 1
			
			if current_level == extraction_intervals.size():
				extractor_interactable.interactions_enabled = [false, false] as Array[bool]
				extractor_interactable.input_names = [repair_action_name, collect_action_name]
				extractor_long_interactable.cancel_input_names = [repair_cancel_name]
				extractor_long_interactable.interaction_times = [repair_time]
				extractor_long_interactable.interaction_names = [repair_interactable_name]
				extractor_long_interactable.intercept_actions = [true] as Array[bool]
			else:
				extractor_interactable.input_names[0] = upgrade_action_name + " (x%d[img=32]%s[/img])" % [upgrade_costs[current_level], scrap_resource.icon.resource_path] 
			extractor_interactable.can_interact = true
		upgrading = false
	elif action_index == 1:
		extractor.extractor_health.heal(extractor.extractor_health.max_health * repair_fraction)


func _on_interactable_interact(input_index: int) -> void:
	if current_level < 0:
		return
	elif current_level < extraction_intervals.size():
		if input_index == 2:
			PlayerInventory.Instance.add_resource(scrap_resource, extractor.accumulated_scrap)
			extractor.accumulated_scrap = 0
			InteractionSystem.Instance.finish_interaction()
	else:
		if input_index == 1:
			PlayerInventory.Instance.add_resource(scrap_resource, extractor.accumulated_scrap)
			extractor.accumulated_scrap = 0
			InteractionSystem.Instance.finish_interaction()
