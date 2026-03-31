## Collection Home Page - Vol.1 Final Bundle
## Handles dynamic path mapping, staggered entry animations, and scene transitions.
extends Control

# --- Path Configuration ---
# Map button names to their respective game scene paths
const GAMES: Dictionary = {
	"Btn_1": "res://Games/01_Piano/main.tscn",
	"Btn_2": "res://Games/02_Coloring/main.tscn",
	"Btn_3": "res://Games/03_Fish/main.tscn",
	"Btn_4": "res://Games/04_Dragonfly/main.tscn",
	"Btn_5": "res://Games/05_Duck/main.tscn"

}

# --- Internal State ---
var all_buttons: Array[Button] = []
var is_transitioning: bool = false 

# --- Lifecycle ---
func _ready() -> void:
	# 1. Collect all buttons from layout containers
	var left_col = get_node_or_null("MarginContainer/VBoxContainer/HBoxContainer/LeftCol")
	var right_col = get_node_or_null("MarginContainer/VBoxContainer/HBoxContainer/RightCol")
	
	if left_col:
		for child in left_col.get_children():
			if child is Button: all_buttons.append(child)
	if right_col:
		for child in right_col.get_children():
			if child is Button: all_buttons.append(child)
		
	# 2. Initialization: Hide buttons and connect signals
	for btn in all_buttons:
		btn.modulate.a = 0.0
		btn.pressed.connect(_on_button_pressed.bind(btn))
		
	# 3. Start sequential entrance sequence
	_play_entrance_sequence()

# --- Animation Logic ---
func _play_entrance_sequence() -> void:
	var tween: Tween = create_tween()
	# Staggered fade-in: 0.15s interval between buttons
	for btn in all_buttons:
		tween.tween_property(btn, "modulate:a", 1.0, 0.1)
		tween.set_parallel(false) # Ensure sequential processing
		tween.tween_interval(0.05) 

# --- Signal Handling ---
func _on_button_pressed(clicked_btn: Button) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	var scene_path: String = GAMES.get(clicked_btn.name, "")
	
	if scene_path == "":
		is_transitioning = false
		return

	# Transition Animation: Highlight selected, fade out others
	var tween: Tween = create_tween().set_parallel(true)
	
	for btn in all_buttons:
		if btn == clicked_btn:
			# Highlight selected (Golden Yellow)
			tween.tween_property(btn, "modulate", Color(1.0, 0.8, 0.2), 0.4)
		else:
			# Fade out unselected
			tween.tween_property(btn, "modulate:a", 0.0, 0.4)
			
	# Wait for animation to finish then switch scene
	tween.chain().tween_callback(func():
		get_tree().change_scene_to_file(scene_path)
	)
