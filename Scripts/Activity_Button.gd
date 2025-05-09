extends Button

@export var grid_map: GridMap  # Make sure this is assigned in the Inspector!
@export var tower_scene: PackedScene  # Your tower scene
@onready var camera: Camera3D = $SpringArm3D/Camera3D

var is_dragging = false
var tower_preview = null



func _on_button_down():
	is_dragging = true
	print("Start dragging")

func _on_button_up():
	is_dragging = false
	print("Tower placed")
