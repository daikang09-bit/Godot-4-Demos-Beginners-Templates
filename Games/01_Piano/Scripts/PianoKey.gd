## Piano Simulator - Vol.1 Game 01
## Features: Hover visuals and input reporting to the main controller.
## Optimized for Godot 4.x with strict typing.
extends Area2D

# --- Configuration ---
@export_group("Note Settings")
@export var note_index: int = 1
@export var cooldown_time: float = 0.5 

@export_group("Visuals")
@export var hover_glow: Color = Color(1.5, 1.5, 1.5) 
@export var normal_color: Color = Color(1, 1, 1)

# --- State ---
var _can_click: bool = true
var _tween: Tween 

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _main_director: Node = get_tree().current_scene 

func _ready() -> void:
	# Setup hover signals
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))

func _on_hover(is_hover: bool) -> void:
	if not _sprite: return
	
	# Prevent color flickering
	if _tween: _tween.kill()
	_tween = create_tween()
	
	var target: Color = hover_glow if is_hover else normal_color
	_tween.tween_property(_sprite, "modulate", target, 0.1)

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	# Trigger note on left click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _can_click:
			_trigger_note()

func _trigger_note() -> void:
	# Report to main controller
	if is_instance_valid(_main_director) and _main_director.has_method("play_note_input"):
		_main_director.play_note_input(note_index)
	
	# Handle cooldown
	_can_click = false
	await get_tree().create_timer(cooldown_time).timeout
	_can_click = true
