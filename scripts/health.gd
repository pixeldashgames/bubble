class_name Health extends Node3D

signal death

@export var team: String
@export var max_health: float

var health: float
var is_dead := false

func _ready() -> void:
	health = max_health

func damage(amount: float):
	if is_dead:
		return
	
	health = clampf(health - amount, 0, max_health)
	if health <= 0.0001:
		is_dead = true
		death.emit()

func heal(amount: float):
	if is_dead:
		return
	health = clampf(health + amount, 0, max_health)
