extends Node3D

@export var rotation_speed = 1.0
@export var zoom_speed = 2.0
@export var min_zoom = 2.0
@export var max_zoom = 10.0

var angle = 90  # Default angle

func _process(delta):
	if Input.is_action_pressed("Turn Left"):
		rotate_y(rotation_speed * delta)
	if Input.is_action_pressed("Turn Right"):
		rotate_y(-rotation_speed * delta)

	# Optional zoom (scroll up/down)
	var zoom = $SpringArm3D.spring_length
	if Input.is_action_just_pressed("Zoom In"):
		zoom = max(min_zoom, zoom - zoom_speed)
	if Input.is_action_just_pressed("Zoom Out"):
		zoom = min(max_zoom, zoom + zoom_speed)

	$SpringArm3D.spring_length = zoom
