class_name Health extends Node3D

signal death
signal revive
signal damaged

@export var team: String
@export var max_health: float
@export var enabled := true

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
		health = 0
		death.emit()
	elif amount > 0:
		damaged.emit()

func heal(amount: float):
	if health == 0 and amount > 0 and max_health > 0:
		revive.emit()
		is_dead = false
		
	health = clampf(health + amount, 0, max_health)
