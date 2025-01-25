class_name DialogSystem extends Node

const DialogSkipCooldown = 100

static var Instance: DialogSystem

@export var hud: PlayerHUD
@export var dialog_skip_input: GUIDEAction

var last_dialog_time: int = -1000

func _enter_tree() -> void:
	assert(Instance == null, "There is already one instance of the DialogSystem running")
	Instance = self
	
	dialog_skip_input.triggered.connect(_on_dialog_skip)

func _exit_tree() -> void:
	Instance = null

func show_dialog(text: String) -> bool:
	last_dialog_time = Time.get_ticks_msec()
	
	if hud.trying_to_display_dialog:
		return false
	hud.show_dialog(text)
	return true
		

func _on_dialog_skip() -> void:	
	if Time.get_ticks_msec() - last_dialog_time < DialogSkipCooldown:
		return
		
	hud.skip_dialog()
