class_name PlayerHUD extends MarginContainer

static var Instance: PlayerHUD

@export var inventory: PlayerInventory
@export var scrap_resource: GameResource
@export var dialog_box_show_time: float
@export var dialog_box_hide_time: float
@export var dialog_time_per_character: float
@export var dialog_min_time: float
@export var interactable_name_label: RichTextLabel
@export var interact_actions_labels: Array[RichTextLabel]
@export var interact_input_actions: Array[GUIDEAction]
@export var interact_actions_spacers: Array[Control]
@export var input_context: GUIDEMappingContext
@export var interaction_progress_bar: ProgressBar
@export var disabled_interaction_color: Color

var dialog_tween: Tween = null
var hide_tween: Tween = null
var trying_to_display_dialog := false
var interact_input_texts: Array[String] = []

var interact_actions_compiled = false

var input_formatter: GUIDEInputFormatter

func _ready() -> void:
	input_formatter = GUIDEInputFormatter.for_context(input_context)

	for action in interact_input_actions:
		var action_text := await input_formatter.action_as_richtext_async(action)
		interact_input_texts.append(action_text)
	
	interact_actions_compiled = true

func _enter_tree() -> void:
	assert(Instance == null, "Another HUD instance already exists")
	
	Instance = self

func _exit_tree() -> void:
	Instance = null

func _process(_delta: float) -> void:
	%ScrapCounterLabel.text = "x %d" % inventory.get_resource_amount(scrap_resource)

func show_interactable(interactable_name: String, input_names: Array[String], interactions_enabled: Array[bool]):
	hide_interactable()
	interactable_name_label.text = interactable_name
	interactable_name_label.show()
	
	while not interact_actions_compiled:
		await get_tree().process_frame
	
	if input_names.size() == 0:
		return
	
	interact_actions_labels[0].text = interact_input_texts[0] + " " + input_names[0]
	interact_actions_labels[0].show()
	
	if interactions_enabled[0]:
		interact_actions_labels[0].modulate = Color.WHITE
	else:
		interact_actions_labels[0].modulate = disabled_interaction_color
	
	for i in range(1, input_names.size()):
		interact_actions_labels[i].text = interact_input_texts[i] + " " + input_names[i]
		if interactions_enabled[i]:
			interact_actions_labels[i].modulate = Color.WHITE
		else:
			interact_actions_labels[i].modulate = disabled_interaction_color
			
		interact_actions_labels[i].show()
		interact_actions_spacers[i - 1].show()

func hide_interactable():
	interactable_name_label.hide()
	for label in interact_actions_labels:
		label.hide()
	for spacer in interact_actions_spacers:
		spacer.hide()

func show_interaction_progress(progress: float):
	interaction_progress_bar.value = progress
	interaction_progress_bar.show()

func hide_interaction_progress():
	interaction_progress_bar.hide()

func skip_dialog():
	if hide_tween != null and is_instance_valid(hide_tween) and hide_tween.is_running():
		return hide_tween.finished
		
	if dialog_tween == null or not is_instance_valid(dialog_tween) or not dialog_tween.is_running():
		return null
		
	dialog_tween.stop()
	
	hide_tween = create_tween()
	hide_tween.tween_property(%DialogBackdrop, "modulate", Color(1,1,1,0), dialog_box_hide_time)
	
	return hide_tween.finished

func show_dialog(text: String) -> void:
	trying_to_display_dialog = true
	await skip_dialog()
	
	%DialogText.text = text
	
	dialog_tween = create_tween()
	dialog_tween.tween_property(%DialogBackdrop, "modulate", Color(1, 1, 1, 1), dialog_box_show_time)
	dialog_tween.tween_interval(max(dialog_min_time, text.length() * dialog_time_per_character))
	dialog_tween.tween_property(%DialogBackdrop, "modulate", Color(1,1,1,0), dialog_box_hide_time)
	
	trying_to_display_dialog = false
