extends Node3D

@onready var spring_arm = $SpringArm3D
@onready var camera = $SpringArm3D/Camera3D
@onready var orbit_pivot = $"."

# Camera Movement
@export var rotation_speed: float = 0.005
@export var zoom_speed: float = 1.0
@export var min_zoom: float = 3.0
@export var max_zoom: float = 9.0
@export var zoom_smoothness: float = 6.0  # Higher = smoother
@export var min_pitch: float = -55.0  # Min pitch angle (down)
@export var max_pitch: float = -10.0  # Max pitch angle (up)
var target_orbit_position = null
@onready var tower_amount_lb_1: Label = $"../ActivityBut/Tower_amount_lb_1"
@onready var tower_amount_lb_2: Label = $"../ActivityBut2/Tower_amount_lb_2"
@onready var tower_amount_lb_3: Label = $"../ActivityBut3/Tower_amount_lb_3"
@onready var tower_amount_lb_4: Label = $"../ActivityBut4/Tower_amount_lb_4"
@onready var tower_amount_lb_5: Label = $"../ActivityBut5/Tower_amount_lb_5"

# Tower Placement System
@export var tower_scene1: PackedScene
@export var tower_scene2: PackedScene
@export var tower_scene3: PackedScene
@export var tower_scene4: PackedScene
@export var tower_scene5: PackedScene
var tower_previews = null
var tower_preview: Node3D = null
var rotating: bool = false
var target_zoom: float
var current_pitch: float = 0.0
var can_place_tower = not tower_preview or not tower_preview.visible
var blocked_tiles = [4, 5, 6, 9, 10, 12, 13, 14, 15, 16, 17, 18, 21, 22, 23, 24, 28, 29, 30, 31, 32, 42]
var is_tower_1_selected := false
var is_tower_2_selected := false





@onready var tower_amount_labels = {
	1: $"../ActivityBut/Tower_amount_lb_1",
	2: $"../ActivityBut2/Tower_amount_lb_2",
	3: $"../ActivityBut3/Tower_amount_lb_3",
	4: $"../ActivityBut4/Tower_amount_lb_4",
	5: $"../ActivityBut5/Tower_amount_lb_5",
}

@onready var grid_map = $"../GridLower"
@onready var grid_main = $"../GridMain"
@onready var gridmid = $"../Gridmid"

func _ready():
	target_zoom = 6  # Start zoom
	current_pitch = rotation_degrees.x  # Store initial pitch
	for i in range(1, 5):
		tower_amount_labels[i].text = "x" + str(Global.placement_left[i])


func _input(event):
	# Right-click for rotation
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			rotating = event.pressed

	# Rotate when right-click is held
	if event is InputEventMouseMotion and rotating:
		rotate_y(-event.relative.x * rotation_speed)  # Left-right rotation
		
		# Clamp pitch
		current_pitch = clamp(current_pitch - event.relative.y * rotation_speed * 50.0, min_pitch, max_pitch)
		rotation_degrees.x = current_pitch  # Apply clamped pitch

	# Smooth Zoom Input (stores target zoom instead of instant change)
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("Zoom In"):
			target_zoom = max(min_zoom, target_zoom - zoom_speed)
		elif Input.is_action_just_pressed("Zoom Out"):
			target_zoom = min(max_zoom, target_zoom + zoom_speed)
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000  # Cast a long ray
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collide_with_areas = true
		query.collide_with_bodies = true
		var result = space_state.intersect_ray(query)
		
		if result:
			var hit_position = result.position
			target_orbit_position = hit_position
		else:
			print("No hit from raycast")
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if tower_preview and tower_preview.visible:
			if tower_preview.scene_file_path == tower_scene1.resource_path:
				place_tower(1)
			elif tower_preview.scene_file_path == tower_scene2.resource_path:
				place_tower(2)
			elif tower_preview.scene_file_path == tower_scene3.resource_path:
				place_tower(3)
			elif tower_preview.scene_file_path == tower_scene4.resource_path:
				place_tower(4)
			elif tower_preview.scene_file_path == tower_scene5.resource_path:
				place_tower(5)

		# After placing, delete the preview
		if is_instance_valid(tower_preview):
			tower_preview.queue_free()
		tower_preview = null




func create_tower_preview(tower_scene_select):
	
	match tower_scene_select:
		1:
			tower_previews = tower_scene1
		2:
			tower_previews = tower_scene2
		3:
			tower_previews = tower_scene3
		4:
			tower_previews = tower_scene4
		5:
			tower_previews = tower_scene5

	if tower_previews and Global.placement_left[tower_scene_select] > 0:
		tower_preview = tower_previews.instantiate()
		add_child(tower_preview)
		tower_preview.process_mode = Node.PROCESS_MODE_DISABLED

func update_tower_position():
	if not camera or not tower_preview:
		return  # 👈 Avoid using a null tower_preview

	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000  # Cast a long ray
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = 1
	var result = space_state.intersect_ray(query)

	if result: # if the ray hits something

		if result.collider.is_in_group("Enemygro"):
			can_place_tower = false
			return

		if result.collider.is_in_group("Towergro"):
			tower_preview.visible = false
			can_place_tower = false  # Disable placement
			return  # Exit early so we don't update the preview
		else:
			can_place_tower = true  # Allow placement if not over a tower

		if result.collider == grid_map:
			var hit_pos = result.position  # World position of the raycast hit
			var grid_pos = grid_map.local_to_map(grid_map.to_local(hit_pos))  # Convert to grid coords
			var tile_id = grid_map.get_cell_item(grid_pos)

			if tile_id == 43:  # Example: tile ID 4 is a blocked tile
				tower_preview.visible = false
				can_place_tower = false
				return
			else:
				can_place_tower = true
				

		if result.collider == grid_main:
			var hit_pos = result.position  # World position of the raycast hit
			var grid_pos = grid_main.local_to_map(grid_main.to_local(hit_pos))  # Convert to grid coords
			var tile_id = grid_main.get_cell_item(grid_pos)

			if tile_id in blocked_tiles:  # Example: tile ID 4 is a blocked tile
				tower_preview.visible = false
				can_place_tower = false
				return
			else:
				can_place_tower = true

		if result.collider == gridmid:
			var hit_pos = result.position  # World position of the raycast hit
			var grid_pos = gridmid.local_to_map(gridmid.to_local(hit_pos))  # Convert to grid coords
			var tile_id = gridmid.get_cell_item(grid_pos)

			if tile_id == 44:  # Example: tile ID 4 is a blocked tile
				tower_preview.visible = false
				can_place_tower = false
				return
			else:
				can_place_tower = true

		var collision_point = result.position
		var height_offset = -0.03  # Adjust as needed
		var new_pos = collision_point + Vector3(0, height_offset, 0)
		# Force the preview to have no rotation (upright) in global space
		tower_preview.global_position = new_pos
		tower_preview.global_rotation = Vector3.ZERO

		tower_preview.visible = true
	else:
		tower_preview.visible = false

func clear_existing_preview():
	if tower_preview and is_instance_valid(tower_preview):
		tower_preview.queue_free()
	tower_preview = null

func _physics_process(delta):

	tower_amount_lb_1.text = "x" + str(Global.placement_left[1])
	tower_amount_lb_2.text = "x" + str(Global.placement_left[2])
	tower_amount_lb_3.text = "x" + str(Global.placement_left[3])
	tower_amount_lb_4.text = "x" + str(Global.placement_left[4])
	tower_amount_lb_5.text = "x" + str(Global.placement_left[5])

	if Input.is_action_just_pressed("Place Tower 1"):
		clear_existing_preview()
		create_tower_preview(1)
	elif Input.is_action_just_pressed("Place Tower 2"):
		clear_existing_preview()
		create_tower_preview(2)
	elif Input.is_action_just_pressed("Place Tower 3"):
		clear_existing_preview()
		create_tower_preview(3)
	elif Input.is_action_just_pressed("Place Tower 4"):
		clear_existing_preview()
		create_tower_preview(4)
	elif Input.is_action_just_pressed("Place Tower 5"):
		clear_existing_preview()
		create_tower_preview(5)

	spring_arm.spring_length = lerp(spring_arm.spring_length, target_zoom, delta * zoom_smoothness)
	if tower_preview:
		update_tower_position()
	if target_orbit_position:
		var current = orbit_pivot.global_transform.origin
		var new_pos = current.lerp(target_orbit_position, delta * 5)
		orbit_pivot.global_transform.origin = new_pos

func place_tower(tower_number):
	if not can_place_tower:
		print("Can't place a tower here!")
		return

	# Check if we've reached the max placement for this specific tower
	if Global.placement_current[tower_number] >= Global.placement_max[tower_number]:
		print("Max towers placed for tower", tower_number)
		return
	

	var tower_scenes = {
		1: tower_scene1,
		2: tower_scene2,
		3: tower_scene3,
		4: tower_scene4,
		5: tower_scene5
	}
	
	var selected_tower_scene = tower_scenes.get(tower_number, null)

	if selected_tower_scene:
		var new_tower = selected_tower_scene.instantiate()
		get_parent().add_child(new_tower)
		if tower_preview and is_instance_valid(tower_preview) and new_tower:
			# now it’s safe
			new_tower.global_transform = tower_preview.global_transform
			get_parent().add_child(new_tower)
		else:
			push_error("Cannot set transform – either preview or new_tower is invalid.")
			return

		Global.placement_current[tower_number] += 1
		Global.placement_left[tower_number] = Global.placement_max[tower_number] - Global.placement_current[tower_number]
	
		print("Tower", tower_number, "placed. Remaining:", Global.placement_left[tower_number])
	else:
		print("Invalid tower number:", tower_number)


func _on_activity_but_toggled(button_pressed):
	clear_existing_preview()
	if button_pressed:
		create_tower_preview(1)
	else:
		place_tower(1)
		Global.placement_left[1] = Global.placement_max[1] - Global.placement_current[1]
		print(Global.placement_left[1])
		if not tower_preview == null:
			tower_preview.queue_free()


func _on_activity_but_2_toggled(button_pressed):
	clear_existing_preview()
	if button_pressed:
		create_tower_preview(2)
	else:
		place_tower(2)
		Global.placement_left[2] = Global.placement_max[2] - Global.placement_current[2]
		print(Global.placement_left[2])
		if not tower_preview == null:
			tower_preview.queue_free()

func _on_activity_but_3_toggled(button_pressed):
	clear_existing_preview()
	if button_pressed:
		create_tower_preview(3)
	else:
		place_tower(3)
		Global.placement_left[3] = Global.placement_max[3] - Global.placement_current[3]
		print(Global.placement_left[3])
		if not tower_preview == null:
			tower_preview.queue_free()

func _on_activity_but_4_toggled(button_pressed):
	clear_existing_preview()
	if button_pressed:
		create_tower_preview(4)
	else:
		place_tower(4)
		Global.placement_left[4] = Global.placement_max[4] - Global.placement_current[4]
		print(Global.placement_left[4])
		if not tower_preview == null:
			tower_preview.queue_free()


func _on_activity_but_5_toggled(button_pressed):
	clear_existing_preview()
	if button_pressed:
		create_tower_preview(5)
	else:
		place_tower(5)
		Global.placement_left[5] = Global.placement_max[5] - Global.placement_current[5]
		print(Global.placement_left[5])
		if not tower_preview == null:
			tower_preview.queue_free()
