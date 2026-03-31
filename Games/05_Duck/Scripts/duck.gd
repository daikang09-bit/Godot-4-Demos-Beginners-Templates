## Individual Duck Logic - Vol.1 Game 05
## Handles leaf probability and rotation animation.
extends Area2D

# --- Configuration ---
# Reference to the main director node
@export var director: Node2D 
# Sprite representing the leaf in mouth
@export var leaf: Sprite2D 
# Sound effect for interaction
@export var music: AudioStreamPlayer 
# Specific index in director's flag_list
@export var flag_index: int 

# Local state flag
var mouse_flag: int = 0

# --- Lifecycle ---
func _ready() -> void:
	# Connect input event for mouse detection
	self.input_event.connect(_on_input_event)
	
	# Initial state: hide leaf
	if leaf:
		leaf.visible = false

# --- Interaction ---
func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	# Trigger on Left Mouse Button click
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		process_interaction()

# --- Core Logic ---
func process_interaction() -> void:
	# Play interaction audio
	if is_instance_valid(music):
		music.play()
	
	# Rotation animation sequence
	var tween: Tween = create_tween()
	tween.tween_property(self, "rotation_degrees", -90, 0.4)
	tween.tween_property(self, "rotation_degrees", 0, 0.4)
	
	# Wait for animation timing
	await get_tree().create_timer(0.7).timeout
	
	# Calculate leaf probability (0 or 1)
	var random_val: int = randi() % 2 
	if random_val == 1:
		# Update visuals and local state
		if leaf:
			leaf.visible = true
		mouse_flag = 1
		
		# Notify director and update global flag_list
		if director and "flag_list" in director:
			director.flag_list[flag_index] = 1
			if director.has_method("juge_go"):
				director.juge_go()

# --- Utility ---
## Resets duck to initial state
func reset_duck() -> void:
	mouse_flag = 0
	if leaf:
		leaf.visible = false
