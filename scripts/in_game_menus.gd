class_name InGameMenus extends Control

static var Instance: InGameMenus

func _enter_tree() -> void:
	assert(Instance == null, "Tried to create an instance of InGameMenus but one already exists")
	Instance = self

func _exit_tree() -> void:
	Instance = null


func show_pause_menu():
	%PauseMenu.show()
	$Backdrop.show()


func show_game_over_menu():
	%DefeatMenu.show()
	$Backdrop.show()


func show_victory_menu():
	%VictoryMenu.show()
	$Backdrop.show()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_continue_button_pressed() -> void:
	%PauseMenu.hide()
	$Backdrop.hide()


func _on_play_again_button_pressed() -> void:
	get_tree().reload_current_scene()
