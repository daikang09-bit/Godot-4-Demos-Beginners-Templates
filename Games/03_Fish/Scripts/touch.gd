## Fish Hunter - Vol.1 Game 03
## Features: Touch-triggered jump mechanics and simultaneous tween animations.
## Optimized for Godot 4.x with strict typing.
extends Node2D

# --- Configuration ---
@export var target_node: Node2D

# --- State ---
var _is_locked: bool = false

func _unhandled_input(event: InputEvent) -> void:
	# Respond to mouse click or screen touch
	var is_click: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	var is_touch: bool = event is InputEventScreenTouch and event.pressed
	
	if (is_click or is_touch) and not _is_locked:
		_trigger_jump_sequence(event.position)

func _trigger_jump_sequence(input_pos: Vector2) -> void:
	_is_locked = true
	
	# Initial position setup
	target_node.position = Vector2(input_pos.x - 700, 180)
	
	# Parallel movement (X-axis)
	var move_tween: Tween = create_tween().set_parallel(true)
	move_tween.tween_property(target_node, "position:x", target_node.position.x + 500, 0.8)
	
	# Vertical jump effect (Y-axis)
	var jump_tween: Tween = create_tween()
	jump_tween.tween_property(target_node, "position:y", target_node.position.y - 210, 0.4)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(target_node, "position:y", target_node.position.y, 0.4)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Rotation animation sequence
	var rot_tween: Tween = create_tween()
	rot_tween.tween_property(target_node, "rotation_degrees", 0.0, 0.4)
	rot_tween.tween_property(target_node, "rotation_degrees", 40.0, 0.4)
	rot_tween.tween_property(target_node, "rotation_degrees", -40.0, 0.01)
	
	# Cooldown to unlock input
	get_tree().create_timer(0.85).timeout.connect(func(): _is_locked = false)
