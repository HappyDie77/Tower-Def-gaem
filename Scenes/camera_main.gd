extends Node3D

@export var rotation_speed: float = 0.005
@export var zoom_speed: float = 2.0
@export var min_zoom: float = 5.0
@export var max_zoom: float = 30.0
@export var zoom_smoothness: float = 12.0  # Higher = smoother

var rotating: bool = false
var target_zoom: float

@onready var spring_arm = $SpringArm3D

func _ready():
	target_zoom = 10  # Start at current zoom

func _input(event):
	# Detect right-click for rotation
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			rotating = event.pressed

	# Rotate around the center when right-click is held
	if event is InputEventMouseMotion and rotating:
		rotate_y(-event.relative.x * rotation_speed)

	# Smooth Zoom Input (stores target zoom instead of instant change)
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("Zoom In"):
			target_zoom = max(min_zoom, target_zoom - zoom_speed)
		elif Input.is_action_just_pressed("Zoom Out"):
			target_zoom = min(max_zoom, target_zoom + zoom_speed)

func _process(delta):
	# Smoothly interpolate towards the target zoom
	spring_arm.spring_length = lerp(spring_arm.spring_length, target_zoom, delta * zoom_smoothness)
