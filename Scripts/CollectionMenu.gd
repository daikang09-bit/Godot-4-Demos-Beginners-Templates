## Support Button Logic - Vol.1 v1.21
## Handles external link redirection to itch.io
extends Button

# --- Configuration ---
# 🚨 Replace with your actual itch.io project URL
@export var itch_url: String = "https://godotexamplehub.itch.io/godot4-lesson1"

func _ready() -> void:
	# Connect the pressed signal to our local function
	pressed.connect(_on_support_pressed)

func _on_support_pressed() -> void:
	# Standard Godot command to open a web browser
	if itch_url != "":
		OS.shell_open(itch_url)
		print("Redirecting to: ", itch_url)
