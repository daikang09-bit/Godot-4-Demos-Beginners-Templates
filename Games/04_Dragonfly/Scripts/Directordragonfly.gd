## Dragonfly Puzzle - Vol.1 Game 04
## Features: Precise angle detection, AnimatedSprite2D support, and global flight.
extends Node2D

# --- Configuration ---
@export var dragonfly_list: Array[Node2D] = []

# --- Resources ---
@onready var sfx_player: AudioStreamPlayer2D = $AudioPlayer 

func _ready() -> void:
	# Initialize random seed for playthrough variety
	randomize()

## Validates if all dragonflies share the same angle
func judge_equal() -> void:
	if dragonfly_list.is_empty(): 
		return

	# Normalize first angle to 0-359 range
	var ref_angle: int = int(posmod(round(dragonfly_list[0].rotation_degrees), 360))
	var is_aligned: bool = true
	
	for i in range(1, dragonfly_list.size()):
		var cur_angle: int = int(posmod(round(dragonfly_list[i].rotation_degrees), 360))
		if cur_angle != ref_angle:
			is_aligned = false
			break
	
	if is_aligned:
		_trigger_success_sequence()

## Triggers SFX, animations, and flight paths
func _trigger_success_sequence() -> void:
	if is_instance_valid(sfx_player) and not sfx_player.playing:
		sfx_player.play()
	
	for dragonfly in dragonfly_list:
		if not is_instance_valid(dragonfly): 
			continue
		
		# FIX: Search for AnimatedSprite2D instead of AnimationPlayer
		_force_play_animation(dragonfly)
		_execute_flight_path(dragonfly)

## Recursively finds and plays AnimatedSprite2D animations
func _force_play_animation(target: Node2D) -> void:
	for child in target.get_children():
		if child is AnimatedSprite2D:
			var res = child.sprite_frames
			if res:
				# Play "fly_anim" or first available animation
				if res.has_animation("fly_anim"):
					child.play("fly_anim")
				else:
					var anims = res.get_animation_names()
					if anims.size() > 0: child.play(anims[0])
			break

## Handles movement using global coordinates for screen exit
func _execute_flight_path(target: Node2D) -> void:
	var move_vec: Vector2 = Vector2.ZERO
	var angle: int = int(posmod(round(target.rotation_degrees), 360))
	
	# Determine direction; 1500px ensures clearing the viewport
	match angle:
		0, 360: move_vec = Vector2(0, -1500)   # Up
		90:     move_vec = Vector2(1500, 0)    # Right
		180:    move_vec = Vector2(0, 1500)    # Down
		270:    move_vec = Vector2(-1500, 0)   # Left
		_:      move_vec = Vector2.UP.rotated(target.rotation) * 1500
	
	var tween: Tween = create_tween()
	tween.tween_property(target, "global_position", target.global_position + move_vec, 2.5)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	
	# Connect reset to the last movement finish
	if target == dragonfly_list.back():
		tween.finished.connect(all_reset)

## Resets all nodes to their initial/random states
func all_reset() -> void:
	for dragonfly in dragonfly_list:
		if not is_instance_valid(dragonfly): 
			continue
		
		dragonfly.visible = true
		
		# Stop any AnimatedSprite2D animations
		for child in dragonfly.get_children():
			if child is AnimatedSprite2D:
				child.stop()
		
		if dragonfly.has_method("reset_position"):
			dragonfly.call("reset_position")
		if dragonfly.has_method("randomize_angle"):
			dragonfly.call("randomize_angle")
