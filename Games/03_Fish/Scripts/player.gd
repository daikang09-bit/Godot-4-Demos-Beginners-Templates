## Fish Hunter - Vol.1 Game 03
## Features: Constant horizontal movement and random respawn logic.
## Optimized for Godot 4.x with strict typing.
extends Area2D

# --- Settings ---
@export var speed: float = 200.0
@export var right_boundary: float = 800.0

# --- State ---
var _spawn_x: float = 0.0

func _ready() -> void:
	# Store the initial X-position as the base for respawning
	_spawn_x = position.x

func _process(delta: float) -> void:
	# Constant rightward movement
	position.x += speed * delta
	
	# Check if object passed the right boundary
	if position.x >= right_boundary:
		# Reset to a random position to the left of the spawn point
		position.x = _spawn_x - randf_range(0, 800)
