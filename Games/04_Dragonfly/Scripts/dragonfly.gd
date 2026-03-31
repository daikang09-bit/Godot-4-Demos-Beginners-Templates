## Individual Dragonfly Logic - Vol.1 Game 04
## Handles click rotation and state resetting.
extends Area2D

# --- Variables ---
@onready var director: Node2D = get_parent()
var initial_pos: Vector2

# --- Lifecycle ---
func _ready() -> void:
	# Store starting position for reset logic
	initial_pos = global_position
	# Initial random orientation
	randomize_angle()

# --- Input Handling ---
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	# Trigger rotation on Left Mouse Button click
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		rotate_90_degrees()

# --- Core Logic ---
func rotate_90_degrees() -> void:
	# FIX: Use wrapf to avoid float-to-int conversion warnings
	rotation_degrees = wrapf(rotation_degrees + 90, 0, 360)
	
	# Notify director to check win condition
	if director and director.has_method("judge_equal"):
		director.judge_equal()

# --- Utility Functions ---
## Snaps node back to original starting coordinates
func reset_position() -> void:
	global_position = initial_pos

## Picks a random orthogonal angle (0, 90, 180, 270)
func randomize_angle() -> void:
	var angles: Array = [0.0, 90.0, 180.0, 270.0]
	rotation_degrees = angles[randi() % angles.size()]
