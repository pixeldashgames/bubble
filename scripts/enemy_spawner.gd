class_name EnemySpawner extends Node3D

@export var enemy_scene: PackedScene
@export var spawner_radius: float
@export var general_enemy_objective: Health

var last_spawn_time := 0.0

var spawn_rate := 0.0
var spawn_count := 0

func _process(delta: float) -> void:
	if spawn_count <= 0:
		return
	
	var time = Time.get_ticks_msec()
	
	if time - last_spawn_time < spawn_rate:
		return
	
	last_spawn_time = time

	var direction = Vector3(randf() - 0.5, 0, randf() - 0.5).normalized()
	var pos = global_position + direction * spawner_radius * randf()
	
	var inst = enemy_scene.instantiate() as Enemy
	get_tree().root.add_child(inst)
	spawn_count -= 1
	inst.global_position = pos
	inst.set_general_objective(general_enemy_objective)

func start_wave(enemies_count: int, rate: float):
	spawn_count = enemies_count
	spawn_rate = rate
	last_spawn_time = Time.get_ticks_msec()
