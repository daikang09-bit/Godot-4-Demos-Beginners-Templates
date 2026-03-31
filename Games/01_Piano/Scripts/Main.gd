## Piano Simulator - Vol.1 Game 01
## Features: Note recording, visual instantiation, and sequence playback.
## Optimized for Godot 4.x with strict typing.
extends Node2D

const MAX_COUNT: int = 16

@export_group("Resources")
@export var note_scenes: Array[PackedScene] = []
@export var audio_players: Array[AudioStreamPlayer] = []

@export_group("Layout Settings")
@export var first_x: float = 100.0
@export var distance: float = 40.0

# --- State Management ---
var head_p: int = 0
var recorded_notes: Array[int] = []
var active_note_nodes: Array[Node2D] = []
var is_playing: bool = false

# Use % for Unique Name access (Remember to set this in Editor!)
@onready var note_display: Node2D = %NoteDisplayArea

const NOTE_CONFIG: Dictionary = {
	1: [0, 220], 2: [1, 220], 3: [2, 210], 4: [3, 200],
	5: [2, 200], 6: [2, 190], 7: [4, 190], 8: [2, 180],
	9: [3, 180], 10: [2, 170], 11: [3, 170], 12: [2, 160],
	13: [5, 210]
}

func _ready() -> void:
	recorded_notes.resize(MAX_COUNT)
	recorded_notes.fill(0)
	
	# Code-based connections are safer for templates
	if has_node("%PlayButton"):
		%PlayButton.pressed.connect(play_recorded_sequence)
	if has_node("%ClearButton"):
		%ClearButton.pressed.connect(clear_notes)

## Public method called by piano keys
func play_note_input(note_index: int) -> void:
	if is_playing or head_p >= MAX_COUNT:
		return

	# CRITICAL FIX: Boundary check to prevent crash if Inspector is incomplete
	if note_index > 0 and note_index <= audio_players.size():
		audio_players[note_index - 1].play()
		recorded_notes[head_p] = note_index
		_spawn_visual_note(note_index, head_p)
		head_p += 1

func _spawn_visual_note(note_index: int, pos_index: int) -> void:
	if not NOTE_CONFIG.has(note_index): return
	if not is_instance_valid(note_display): return # Prevent null pointer error
	
	var config: Array = NOTE_CONFIG[note_index]
	if config[0] < note_scenes.size():
		var scene: PackedScene = note_scenes[config[0]]
		var note_instance: Node2D = scene.instantiate() as Node2D
		
		note_display.add_child(note_instance)
		note_instance.position = Vector2(first_x + pos_index * distance, config[1])
		active_note_nodes.append(note_instance)

func clear_notes() -> void:
	is_playing = false 
	head_p = 0
	for node in active_note_nodes:
		if is_instance_valid(node):
			node.queue_free()
	active_note_nodes.clear()
	recorded_notes.fill(0)

func play_recorded_sequence() -> void:
	if head_p == 0 or is_playing:
		return
		
	is_playing = true
	for i in range(head_p):
		if not is_playing or active_note_nodes.size() <= i: break
			
		var note_index: int = recorded_notes[i]
		var visual_node: Node2D = active_note_nodes[i]
		
		if is_instance_valid(visual_node):
			var tween: Tween = create_tween()
			visual_node.modulate = Color(1.0, 0.92, 0.01)
			tween.tween_property(visual_node, "modulate", Color.WHITE, 0.4)
			
		if note_index > 0 and note_index <= audio_players.size():
			audio_players[note_index - 1].play()
			
		await get_tree().create_timer(0.5).timeout

	is_playing = false
