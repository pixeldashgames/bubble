class_name NPCDialog extends Node

@export var intectable: Interactable
@export var dialogs: Array[String]
@export var repeat_dialogs := true
@export var repeat_start_index: int

var conversation_index: int = 0

func _ready() -> void:
	intectable.interact.connect(on_interact)
	
func on_interact(_action: int) -> void:
	if conversation_index >= dialogs.size():
		if repeat_dialogs:
			conversation_index = repeat_start_index
		else:
			DialogSystem.Instance.show_dialog(dialogs[-1])
			return
	
	if not DialogSystem.Instance.show_dialog(dialogs[conversation_index]):
		return
		
	conversation_index += 1
