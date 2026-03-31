## Coloring Game - Vol.1 Game 02
## Features: Object zooming, color mixing logic, and area-based painting.
## Optimized for Godot 4.x with strict typing.
extends Node2D

# --- Node References ---
@export_group("Required Nodes")
@export var brush: Node2D
@export var brush_head: Sprite2D
@export var things_node: Node2D
@export var palette_node: Node2D
@export var back_btn: Button

# --- State Variables ---
var active_colors: Dictionary = {}
var current_color: Color = Color.TRANSPARENT 
var is_brush_active: bool = false
var is_object_focused: bool = false

# Dictionary to store original transform data for reset
var initial_data: Dictionary = {}

const COLOR_DICT: Dictionary = {
	"blue": Color(0.0, 0.68, 0.94),
	"red": Color(1.0, 0.0, 0.0),
	"yellow": Color(1.0, 1.0, 0.0),
	"black": Color(0.0, 0.0, 0.0),
	"white": Color(1.0, 1.0, 1.0)
}

var SCREEN_CENTER: Vector2

func _ready() -> void:
	# 1. Coordinate System Setup
	var canvas_inv: Transform2D = get_canvas_transform().affine_inverse()
	var view_size: Vector2 = get_viewport_rect().size
	SCREEN_CENTER = canvas_inv * (view_size / 2.0)
	
	# 2. Initial Brush Position
	if brush:
		brush.global_position = canvas_inv * Vector2(view_size.x - 150, view_size.y - 70)
	if brush_head:
		brush_head.visible = false
	
	# 3. Record Initial Transformations
	if things_node:
		for obj in things_node.get_children():
			if obj is Node2D:
				initial_data[obj] = {
					"pos": obj.global_position,
					"scale": obj.scale
				}
	
	if back_btn:
		back_btn.pressed.connect(_on_back_btn_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos: Vector2 = get_global_mouse_position()
		
		# Step A: Check Palette Interaction
		if _check_palette_click(mouse_pos):
			return 
			
		# Step B: Physics Point Query for Painting/Focusing
		var space_state := get_world_2d().direct_space_state
		var query := PhysicsPointQueryParameters2D.new()
		query.position = mouse_pos
		query.collide_with_areas = true 
		
		var results := space_state.intersect_point(query)
		
		if results.is_empty():
			_reset_all_objects()
			return
			
		_handle_interaction(results)

func _handle_interaction(results: Array) -> void:
	var hit_patch: Node2D = null
	var hit_object_root: Node2D = null
	
	# Process results from top to bottom
	for i in range(results.size() - 1, -1, -1):
		var area = results[i].collider as Area2D
		if not area: continue
		var parent = area.get_parent()
		
		# Priority 1: Check if it's a paintable patch (Recommended: Add nodes to "paintable" group)
		if parent.is_in_group("paintable") or parent.name.begins_with("patch"):
			hit_patch = parent
		# Priority 2: Check if it's the root object (Recommended: Add to "interactable_root" group)
		elif parent.is_in_group("interactable_root") or parent.name.begins_with("Object"):
			hit_object_root = parent

	if not is_object_focused:
		var target = hit_object_root if hit_object_root else (hit_patch.get_parent() if hit_patch else null)
		if target: _focus_object(target)
	else:
		if hit_patch and is_brush_active:
			hit_patch.self_modulate = current_color

# --- Core Logic: Focus & Reset ---

func _focus_object(target: Node2D) -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(target, "global_position", SCREEN_CENTER, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_QUINT)
	target.z_index = 10
	is_object_focused = true

func _reset_all_objects() -> void:
	if not is_object_focused: return
	
	for obj in initial_data.keys():
		if is_instance_valid(obj):
			var tween := create_tween().set_parallel(true)
			var data: Dictionary = initial_data[obj]
			tween.tween_property(obj, "global_position", data["pos"], 0.4).set_trans(Tween.TRANS_SINE)
			tween.tween_property(obj, "scale", data["scale"], 0.4).set_trans(Tween.TRANS_SINE)
			obj.z_index = 0
		
	is_object_focused = false

# --- Core Logic: Color Management ---

func _check_palette_click(mouse_pos: Vector2) -> bool:
	if not palette_node: return false
	
	for color_btn in palette_node.get_children():
		if color_btn is Sprite2D:
			# FIX: Using get_rect() for Sprite2D instead of get_item_rect()
			if color_btn.get_rect().has_point(color_btn.to_local(mouse_pos)):
				var c_name: String = color_btn.name.to_lower()
				if c_name == "clean":
					active_colors.clear()
				else:
					_handle_color_mixing(c_name)
				_update_brush_visuals()
				return true
	return false

func _handle_color_mixing(c_name: String) -> void:
	if c_name in ["blue", "red", "yellow"]:
		active_colors.erase("white"); active_colors.erase("black")
		active_colors[c_name] = true
	elif c_name in ["black", "white"]:
		active_colors.clear()
		active_colors[c_name] = true

func _update_brush_visuals() -> void:
	var length: int = active_colors.size()
	if length == 0:
		is_brush_active = false
		if brush_head: brush_head.visible = false
		return
		
	var r: float = 0.0; var g: float = 0.0; var b: float = 0.0
	for c in active_colors.keys():
		r += COLOR_DICT[c].r
		g += COLOR_DICT[c].g
		b += COLOR_DICT[c].b
		
	current_color = Color(r / length, g / length, b / length, 1.0)
	is_brush_active = true
	if brush_head:
		brush_head.visible = true
		brush_head.self_modulate = current_color

func _on_back_btn_pressed() -> void:
	# CRITICAL: Update this path to match your Collection Main Menu
	get_tree().change_scene_to_file("res://main.tscn")
