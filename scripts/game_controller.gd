class_name GameController extends Node3D

static var Instance: GameController = null

@export var input_mapping_context: GUIDEMappingContext
@export var waves: Array[WaveDefinition]
@export var spawn_points: Array[EnemySpawner]
@export var pause_action: GUIDEAction

@export var background_music_player: AudioStreamPlayer

var current_wave := 0
var in_preparation := true
var total_enemy_count := 0
var preparation_end_time: float

func _enter_tree() -> void:
	assert(Instance == null, "Tried to instance a GameController but there is one already")
	Instance = self

func _exit_tree() -> void:
	Instance = null

func _ready() -> void:
	GUIDE.enable_mapping_context(input_mapping_context)
	preparation_end_time = Time.get_ticks_msec() + waves[0].preparation_time
	pause_action.triggered.connect(on_pause)

func on_pause() -> void:
	InGameMenus.Instance.show_pause_menu()

func change_background_music(music_stream: AudioStream) -> void:
	var volume = background_music_player.volume_db
	
	var tween = create_tween()
	await tween.tween_property(background_music_player, "volume_db", -50, 1).finished
	
	background_music_player.stream = music_stream
	background_music_player.play()
	tween = create_tween()
	await tween.tween_property(background_music_player, "volume_db", volume, 1).finished
	

func _process(delta: float) -> void:
	if in_preparation:	
		var time = Time.get_ticks_msec()
		
		if time < preparation_end_time:
			PlayerHUD.Instance.update_preparation_hud(roundi((preparation_end_time - time) / 1000.0))
			return
		
		total_enemy_count = 0
		var wave = waves[current_wave]
		
		for i in spawn_points.size():
			var count = wave.spawn_counts[i]
			total_enemy_count += count
			spawn_points[i].start_wave(wave.enemies[i], count, wave.spawn_rates[i])
		
		PlayerHUD.Instance.update_wave_hud(total_enemy_count)
		
		in_preparation = false
	

func on_enemy_killed():
	total_enemy_count -= 1
	PlayerHUD.Instance.update_wave_hud(total_enemy_count)
	
	if total_enemy_count <= 0:
		current_wave += 1
		
		if current_wave == waves.size():
			victory()
			return
		
		in_preparation = true
		preparation_end_time = Time.get_ticks_msec() + waves[current_wave].preparation_time


func on_base_destruction():
	InGameMenus.Instance.show_game_over_menu()

func victory():
	InGameMenus.Instance.show_victory_menu()
