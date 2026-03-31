## Fish Hunter - Vol.1 Game 03
## Features: Collision detection, speed scaling, and reactive animations.
## Optimized for Godot 4.x with strict typing.
extends Area2D
class_name CollisionHandler

# --- Resources ---
@export var sfx_player: AudioStreamPlayer
@export var fish_root: Area2D

func _ready() -> void:
	# Ensure the signal is connected for collision detection
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func _on_area_entered(other: Area2D) -> void:
	# Logic for group "911" obstacles
	if other.is_in_group("911"):
		if is_instance_valid(sfx_player):
			sfx_player.play()
		
		# Locate target node containing 'speed' property
		var target: Node = other if "speed" in other else other.get_parent()
		
		if "speed" in target:
			target.speed += 20
			# Respawn target at random horizontal offset
			target.global_position.x = -500 - randi_range(0, 800)
		
		_play_hit_animation()

func _play_hit_animation() -> void:
	# Critical Safety: Prevent 'Nil' access error from your previous screenshot
	if not is_instance_valid(fish_root):
		push_error("Fish Hunter: fish_root is NOT assigned in the Inspector!")
		return

	# Stop existing tweens to prevent overlap
	for t in get_tree().get_processed_tweens():
		t.kill()
	
	var tween: Tween = create_tween()
	
	# Phase 1: Rotation effect
	tween.tween_property(fish_root, "rotation_degrees", fish_root.rotation_degrees - 300, 0.6)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	# Phase 2: Interval and falling
	tween.tween_interval(0.1)
	tween.chain().tween_property(fish_root, "position", fish_root.position + Vector2(100, 200), 0.4)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Phase 3: Reset rotation state
	tween.chain().tween_property(fish_root, "rotation_degrees", -40.0, 0.01)
