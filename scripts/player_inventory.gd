class_name PlayerInventory extends Node

static var Instance: PlayerInventory

@export var initial_resources: Array[GameResource]
@export var initial_resources_amounts: Array[int]

var inventory: Dictionary

func _ready() -> void:
	if Instance != null:
		assert(false, "More than one inventory loaded.")
	Instance = self
	
	for i in initial_resources.size():
		inventory[initial_resources[i]] = initial_resources_amounts[i]


func _exit_tree() -> void:
	Instance = null


func add_resource(res: GameResource, amount: int) -> void:
	if inventory.has(res):
		inventory[res] += amount
	else:
		inventory[res] = amount


func get_resource_amount(res: GameResource) -> int:
	if not inventory.has(res):
		return 0
	else:
		return inventory[res]
