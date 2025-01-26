class_name Weakpoint extends Node

@export var long_interactable: LongInteractable
@export var interactable: Interactable
@export var repair_fraction: float
@export var health: Health

@export var under_attack_sounds: Array[AudioStream]
@export var under_attack_notification_frequency: int

var last_attack_notification := -9999

func _ready() -> void:
	long_interactable.long_interact.connect(on_long_interact)

func _process(_delta: float) -> void:
	if long_interactable.running:
		return
	
	interactable.interactions_enabled[0] = health.health < health.max_health
	interactable.info_details = get_details()

func get_details() -> String:
	return "Salud       %d/%d" % [health.health, health.max_health]


func on_long_interact(action: int):
	if action == 0:
		health.heal(health.max_health * repair_fraction)


func _on_health_damaged() -> void:
	if Time.get_ticks_msec() - last_attack_notification < under_attack_notification_frequency:
		return
	
	last_attack_notification = Time.get_ticks_msec()
	AIAssistantVoice.Instance.enqueue_notif(under_attack_sounds.pick_random())
