class_name NPCDialog extends Node

@export var intectable: Interactable
@export var dialogs: Array[String]
@export var dialog_sounds: Array[AudioStream]
@export var dialog_sound_source: AudioStreamPlayer3D
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
	
	if dialog_sound_source != null and dialog_sounds.size() > conversation_index and dialog_sounds[conversation_index] != null:
		dialog_sound_source.stop()
		dialog_sound_source.stream = dialog_sounds[conversation_index]
		dialog_sound_source.play()
		
	conversation_index += 1
