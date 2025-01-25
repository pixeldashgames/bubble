extends Area3D

@export var interact_inputs: Array[GUIDEAction]

var current_interactables: Array[Interactable] = [] as Array[Interactable]
var selected_interactable: Interactable = null

var enabled := true

func _ready() -> void:
	for i in interact_inputs.size():
		interact_inputs[i].triggered.connect(on_interact.bind(i))

func update_interactables():
	var highest_priority: int = -99999
	var last_selected := selected_interactable
	selected_interactable = null
	
	if enabled:
		var remove_indexes: Array[int] = []
		for i in current_interactables.size():
			var interactable = current_interactables[i]
			
			if interactable == null or not is_instance_valid(interactable):
				remove_indexes.append(i)
				continue
				
			if not interactable.can_interact:
				continue
			if interactable.interactable_priority > highest_priority:
				highest_priority = interactable.interactable_priority
				selected_interactable = interactable
		
		for index in remove_indexes:
			current_interactables.remove_at(index)
	
	if last_selected != selected_interactable:
		if last_selected != null:
			last_selected.on_deselect()
		if selected_interactable != null:
			selected_interactable.on_select()
	
	if selected_interactable != null:
		PlayerHUD.Instance.show_interactable(selected_interactable.interactable_name, selected_interactable.input_names)
	else:
		PlayerHUD.Instance.hide_interactable()


func _on_body_entered(body: Node3D) -> void:
	if not body is Interactable:
		return
	
	current_interactables.append(body as Interactable)
	
	
func _on_body_exited(body: Node3D) -> void:
	
	if not body is Interactable:
		return
	
	if current_interactables.has(body as Interactable):
		current_interactables.erase(body as Interactable)


func finish_interaction():
	enabled = true


func _process(_delta: float) -> void:
	update_interactables()
	
func on_interact(input_index: int) -> void:
	if selected_interactable == null or selected_interactable.input_names.size() <= input_index:
		return
	
	if selected_interactable.disable_player_on_interaction:
		enabled = false
	
	selected_interactable.on_interact(input_index)
