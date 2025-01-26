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
@export var extractor_health: Health
@export var animation_players: Array[AnimationPlayer]

@export var drilling_sound: AudioStreamPlayer3D

@export var extractor_meshes: Array[Node3D]

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
@export var start_built: bool
@export var running_animation_name: String
@export var stopped_animation_name: String

@export var repair_fraction: float

@export var full_notification: AudioStream

var current_level = -1
var upgrading := false
var stopped_full := false

func _ready() -> void:
	extractor_interactable.input_names = [extractor_interactable.input_names[0] + " (x%d[img=32]%s[/img])" % [build_cost, scrap_resource.icon.resource_path]]
	if start_built:
		_on_long_interactable_long_interact(0)
		
func get_extractor_info() -> String:
	var string = "Salud       %d/%d\n" % [extractor_health.health, extractor_health.max_health]
	string +=    "Almacen.    %d/%d\n" % [extractor.accumulated_scrap, extractor.max_scrap_storage]
	
	string +=   "\nTiempo de Ext.    %d" % roundi(extractor.extraction_interval)
	if current_level < extraction_intervals.size():
		var value := roundi(extraction_intervals[current_level])
		if value != roundi(extractor.extraction_interval):
			string += "  →   [color=green]%d[/color]" % value
			
	string +=   "\nCant. de Ext.     %d" % extractor.extraction_amount
	if current_level < extraction_intervals.size():
		var value = extraction_amounts[current_level]
		if value != extractor.extraction_amount:
			string += "  →   [color=green]%d[/color]" % value
	
	string +=   "\nAlmacen. Máx.     %d" % extractor.max_scrap_storage
	if current_level < extraction_intervals.size():
		var value = storages[current_level]
		if value != extractor.max_scrap_storage:
			string += "  →   [color=green]%d[/color]" % value
	
	string +=   "\nSalud Máx.    %d" % roundi(extractor_health.max_health)
	if current_level < extraction_intervals.size():
		var value = roundi(healths[current_level])
		if not is_equal_approx(value, roundi(extractor_health.max_health)):
			string += "  →   [color=green]%d[/color]" % value
	return string

func _process(_delta: float) -> void:
	if current_level >= 0:
		extractor_interactable.info_details = get_extractor_info()
	
	if upgrading or extractor_long_interactable.running:
		return
	
	var scrap := PlayerInventory.Instance.get_resource_amount(scrap_resource)
	
	if current_level < 0:
		extractor_interactable.interactions_enabled[0] = scrap >= build_cost
		return
	elif current_level < extraction_intervals.size():
		extractor_interactable.interactions_enabled[0] = scrap >= upgrade_costs[current_level]
		extractor_interactable.interactions_enabled[1] = extractor_health.health < extractor_health.max_health
		extractor_interactable.interactions_enabled[2] = extractor.accumulated_scrap > 0
	else:
		extractor_interactable.interactions_enabled[0] = extractor_health.health < extractor_health.max_health
		extractor_interactable.interactions_enabled[1] = extractor.accumulated_scrap > 0
	
	if not stopped_full and current_level >= 0 and extractor.accumulated_scrap >= extractor.max_scrap_storage:
		animation_players[current_level].play(stopped_animation_name)
		drilling_sound.stop()
		stopped_full = true
		AIAssistantVoice.Instance.enqueue_notif(full_notification)
		


func _on_long_interactable_long_interact(action_index: int) -> void:
	if action_index == 0:
		upgrading = true
		if current_level < 0:
			if not start_built:
				PlayerInventory.Instance.extract_resource(scrap_resource, build_cost)
			
			animation_players[0].play(running_animation_name)
			drilling_sound.play()
			
			extractor_interactable.interactable_name = interactable_name + " Lv. 1"
			extractor_interactable.info_title = extractor_interactable.interactable_name
			extractor_interactable.interactions_enabled = [false, false, false] as Array[bool]
			extractor_interactable.input_names = [upgrade_action_name + " (x%d[img=32]%s[/img])" % [upgrade_costs[0], scrap_resource.icon.resource_path], repair_action_name, collect_action_name]
			
			extractor_health.enabled = true
			extractor.enabled = true
			extractor_meshes[0].show()
			
			extractor_long_interactable.cancel_input_names = [upgrade_cancel_name, repair_cancel_name]
			extractor_long_interactable.interaction_times = [upgrade_time, repair_time]
			extractor_long_interactable.interaction_names = [upgrade_interactable_name, repair_interactable_name]
			extractor_long_interactable.intercept_actions = [true, true] as Array[bool]
			current_level = 0
		elif current_level < extraction_intervals.size():
			PlayerInventory.Instance.extract_resource(scrap_resource, build_cost)
			
			if not extractor_health.is_dead:
				animation_players[current_level + 1].play(running_animation_name)
				if stopped_full:
					drilling_sound.play()
			else:
				animation_players[current_level + 1].play(stopped_animation_name)
			
			stopped_full = false
			
			extractor_meshes[current_level].hide()
			extractor_meshes[current_level + 1].show()
			
			if current_level + 1 == extraction_intervals.size():
				extractor_interactable.interactable_name = interactable_name + " Lv. MAX"
			else:
				extractor_interactable.interactable_name = interactable_name + " Lv. " + str(current_level + 2)
			extractor_interactable.info_title = extractor_interactable.interactable_name
			
			extractor.upgrade(extraction_intervals[current_level], extraction_amounts[current_level], storages[current_level])
			var new_health = healths[current_level]
			var new_current_health = new_health * (extractor_health.health / extractor_health.max_health)
			extractor_health.max_health = new_health
			extractor_health.health = new_current_health
			
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
		upgrading = false
		extractor_interactable.info_details = get_extractor_info()
	elif action_index == 1:
		extractor_health.heal(extractor_health.max_health * repair_fraction)


func _on_interactable_interact(input_index: int) -> void:
	if current_level < 0:
		return
	elif current_level < extraction_intervals.size():
		if input_index == 2:
			if extractor.accumulated_scrap == extractor.max_scrap_storage and not extractor_health.is_dead:
				animation_players[current_level].play(running_animation_name)
			
			stopped_full = false
				
			PlayerInventory.Instance.add_resource(scrap_resource, extractor.accumulated_scrap)
			extractor.accumulated_scrap = 0
			InteractionSystem.Instance.finish_interaction()
	else:
		if input_index == 1:
			if extractor.accumulated_scrap == extractor.max_scrap_storage and not extractor_health.is_dead:
				animation_players[current_level].play(running_animation_name)
				drilling_sound.play()
				
			stopped_full = false
			
				
			PlayerInventory.Instance.add_resource(scrap_resource, extractor.accumulated_scrap)
			extractor.accumulated_scrap = 0
			InteractionSystem.Instance.finish_interaction()


func _on_health_death() -> void:
	extractor.enabled = false
	animation_players[current_level].play(stopped_animation_name)
	drilling_sound.stop()
	


func _on_health_revive() -> void:
	extractor.enabled = true
	if extractor.accumulated_scrap < extractor.max_scrap_storage:
		animation_players[current_level].play(running_animation_name)
		drilling_sound.play()
