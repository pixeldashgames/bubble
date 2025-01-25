class_name Pickupable extends Node

@export var interactable: Interactable
@export var game_resource: GameResource
@export var inventory: PlayerInventory
@export var amount_range: Vector2i
@export var parent_node: Node

func _ready() -> void:
	interactable.interact.connect(on_interact)


func on_interact(_action: int) -> void:
	inventory.add_resource(game_resource, randi_range(amount_range.x, amount_range.y))
	interactable.can_interact = false
	parent_node.queue_free()
