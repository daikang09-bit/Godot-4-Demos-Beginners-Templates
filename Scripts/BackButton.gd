extends Button

func _ready():
	pressed.connect(_on_back_pressed)

func _on_back_pressed():
	# 跳转回你的总目录场景
	get_tree().change_scene_to_file("res://Main.tscn")
