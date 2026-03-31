## Duck Puzzle - Vol.1 Game 05
## Features: Progress tracking via flag_list and head container pathing.
extends Node2D

# --- Configuration ---
# Container for all duck nodes
@export var head: Node2D 
# Victory sound effect player
@export var audio_player: AudioStreamPlayer 

# Game state: 0 = No leaf, 1 = Has leaf
var flag_list: Array = [0, 0, 0, 0]

## Main logic to check win condition
func juge_go() -> void:
	# Debug status
	for f in flag_list:
		print(f)
	
	# Count ducks with leaves
	var num: int = 0
	for f in flag_list:
		if f == 1:
			num += 1
			
	# Check if all ducks are ready
	if num == 4:
		# 1. Play success audio
		if is_instance_valid(audio_player):
			audio_player.play()
		
		# 2. Animate: move container left
		var tween: Tween = create_tween()
		tween.tween_property(head, "position:x", head.position.x - 1300, 4.0)
		
		# 3. Wait for sequence completion
		await get_tree().create_timer(6.0).timeout
		
		# 4. Trigger reset
		reset_game()

## Resets game state and visuals
func reset_game() -> void:
	# Clear status list
	for i in range(flag_list.size()):
		flag_list[i] = 0
	
	# Reset each duck child
	for child in head.get_children():
		if child.has_method("reset_duck"):
			child.reset_duck()
	
	# Snap to standby position
	head.position.x = 800
	
	# Animate: move back into view
	var tween: Tween = create_tween()
	tween.tween_property(head, "position:x", head.position.x - 800, 2.0)
