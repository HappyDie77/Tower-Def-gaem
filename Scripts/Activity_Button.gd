extends Button

@export var grid_map: GridMap  # Make sure this is assigned in the Inspector!
@export var tower_scene: PackedScene  # Your tower scene
@onready var camera: Camera3D = $SpringArm3D/Camera3D


var is_dragging = false
var tower_preview = null

func _ready():
	pass

func _physics_process(delta: float) -> void:
	pass

func _on_button_down():
	is_dragging = true
	print("Start dragging")

func _on_button_up():
	is_dragging = false
	print("Tower placed")

func _process(delta):
	if Input.is_action_pressed("Deeeebug"):
		# Get the mouse position in the viewport
		var mouse_position = get_viewport().get_mouse_position()

		# Get the camera's ray origin and direction
		var ray_origin = camera.global_transform.origin
		var ray_direction = camera.project_ray_normal(mouse_position)

		# Cast the ray in the scene
		var space_state = get_viewport().get_wor_3d()
		var raycast_result = space_state.intersect_ray(ray_origin, ray_origin + ray_direction * 1000)

		if raycast_result:
			# If the ray hit something, output the hit position
			print("Hit position: ", raycast_result.position)
			print("Hit object: ", raycast_result.collider)
