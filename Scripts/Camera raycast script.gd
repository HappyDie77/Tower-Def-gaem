extends Camera3D

@onready var ray_cast_3d = $RayCast3D

var mouse_pos: Vector2
var raycast_length = 1000

func _physics_process(delta):
	mouse_pos = get_viewport().get_mouse_position()
	ray_cast_3d.target_position = project_ray_normal(mouse_pos) * 100
	ray_cast_3d.force_raycast_update()
	
	if ray_cast_3d.is_colliding():
		print(mouse_pos)
		print("colliding")
