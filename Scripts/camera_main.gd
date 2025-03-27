extends Node3D
# https://godotshaders.com/shader/wind-waker-water-no-textures-needed/
@onready var spring_arm = $SpringArm3D
@export var rotation_speed: float = 0.005
@export var zoom_speed: float = 2.0
@export var min_zoom: float = 5.0
@export var max_zoom: float = 14.0
@export var zoom_smoothness: float = 12.0  # Higher = smoother
@export var min_pitch: float = -55.0  # Min pitch angle (down)
@export var max_pitch: float = -10.0   # Max pitch angle (up)


var rotating: bool = false
var target_zoom: float
var current_pitch: float = 0.0


func _ready():
	target_zoom = 10  # Start at current zoom
	current_pitch = rotation_degrees.x  # Store initial pitch

func _input(event):
	# Detect right-click for rotation
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			rotating = event.pressed

	# Rotate when right-click is held
	if event is InputEventMouseMotion and rotating:
		rotate_y(-event.relative.x * rotation_speed)  # Left-right rotation
		
		# Calculate new pitch while clamping
		current_pitch = clamp(current_pitch - event.relative.y * rotation_speed * 50.0, min_pitch, max_pitch)
		rotation_degrees.x = current_pitch  # Apply clamped pitch

	# Smooth Zoom Input (stores target zoom instead of instant change)
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("Zoom In"):
			target_zoom = max(min_zoom, target_zoom - zoom_speed)
		elif Input.is_action_just_pressed("Zoom Out"):
			target_zoom = min(max_zoom, target_zoom + zoom_speed)

func _process(delta):
	# Smoothly interpolate towards the target zoom
	spring_arm.spring_length = lerp(spring_arm.spring_length, target_zoom, delta * zoom_smoothness)
