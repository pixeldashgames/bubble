class_name AIAssistantVoice extends Node

static var Instance: AIAssistantVoice

@export var voice_source: AudioStreamPlayer

var notifications_queue: Array[AudioStream]

func _enter_tree() -> void:
	assert(Instance == null, "Tried to create an instance while another one already exists")
	Instance = self

func _exit_tree() -> void:
	Instance = null

func _process(_delta: float) -> void:
	if notifications_queue.size() == 0:
		return
	
	while notifications_queue.size() > 0:
		var item = notifications_queue.pop_front()
		
		voice_source.stream = item
		voice_source.play()
		
		await voice_source.finished

func enqueue_notif(notif: AudioStream):
	notifications_queue.append(notif)
