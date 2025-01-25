class_name Extractor extends Node3D

@export var extraction_interval: float
@export var extraction_amount: int
@export var extractor_health: Health
@export var max_scrap_storage: int
@export var enabled := true

var last_extraction_time: float = 0
var accumulated_scrap := 0

func upgrade(new_extraction_interval: float, new_extraction_amount: int, new_storage: int, new_health: int):
	extraction_interval = new_extraction_interval
	extraction_amount = new_extraction_amount
	max_scrap_storage = new_storage
	var new_current_health = new_health * (extractor_health.health / extractor_health.max_health)
	extractor_health.max_health = new_health
	extractor_health.health = new_current_health

func _process(_delta: float) -> void:
	if not enabled:
		return
	
	if extractor_health.health == 0:
		return
	
	if accumulated_scrap >= max_scrap_storage:
		return
	
	var time = Time.get_ticks_msec()
	if time - last_extraction_time < extraction_interval:
		return
	
	last_extraction_time = time
	
	accumulated_scrap = clampi(accumulated_scrap + extraction_amount, 0, max_scrap_storage)
