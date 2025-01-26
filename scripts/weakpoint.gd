class_name Weakpoint extends Node

@export var long_interactable: LongInteractable
@export var interactable: Interactable
@export var repair_fraction: float
@export var health: Health

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
