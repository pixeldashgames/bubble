extends Node3D

@export var beam_speed: float
@export var beam_lifetime: float

func _ready() -> void:
	get_tree().create_timer(beam_lifetime).timeout.connect(queue_free)


func _process(delta: float) -> void:
	var forward := -global_basis.z
	global_position += forward * beam_speed * delta
