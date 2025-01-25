class_name LongInteractable extends Node

signal long_interact(action_index: int)

@export var interactable: Interactable
@export var cancel_input_names: Array[String]
@export var interaction_names: Array[String]
@export var cancellable: bool = true
@export var interaction_times: Array[float]
@export var intercept_actions: Array[bool]

var interactable_actions: Array[String]
var interactable_priority: int
var interactable_name: String
var running := false
var start_time: float = -99999
var action_index: int = -1
var interactions_enabled: Array[bool]

func _ready() -> void:
	interactable.interact.connect(on_interact)
	interactable.disable_player_on_interaction = true

func _process(_delta: float) -> void:
	if not running:
		return
	
	var elapsed := Time.get_ticks_msec() - start_time
	
	if elapsed >= interaction_times[action_index]:
		running = false
		interactable.input_names = interactable_actions
		interactable.interactable_priority = interactable_priority
		interactable.interactable_name = interactable_name
		interactable.interactions_enabled = interactions_enabled
		
		PlayerHUD.Instance.hide_interaction_progress()
		InteractionSystem.Instance.finish_interaction()
		
		long_interact.emit(action_index)
		return
	
	PlayerHUD.Instance.show_interaction_progress(elapsed / interaction_times[action_index])

func on_interact(action: int) -> void:
	if intercept_actions.size() <= action or not intercept_actions[action]:
		return
	
	if running and cancellable:
		running = false
		interactable.input_names = interactable_actions
		interactable.interactable_priority = interactable_priority
		interactable.interactable_name = interactable_name
		interactable.interactions_enabled = interactions_enabled
		
		PlayerHUD.Instance.hide_interaction_progress()
		InteractionSystem.Instance.finish_interaction()
		return
	
	interactable_actions = interactable.input_names
	interactable_priority = interactable.interactable_priority
	interactable_name = interactable.interactable_name
	interactions_enabled = interactable.interactions_enabled
	
	if cancellable:
		interactable.input_names = [cancel_input_names[action]] as Array[String]
		interactable.interactions_enabled = [true] as Array[bool]
	else:
		interactable.input_names = []
		interactable.interactions_enabled = []
	
	interactable.interactable_name = interaction_names[action]
	interactable.interactable_priority = 999999
	
	start_time = Time.get_ticks_msec()
	action_index = action
	
	running = true
