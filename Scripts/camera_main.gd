extends Node3D

@onready var spring_arm = $SpringArm3D
@onready var camera = $SpringArm3D/Camera3D
@onready var tower_amount_lb = $"../ActivityBut/Tower_amount_lb"
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

# Tower Placement System
@export var tower_scene1: PackedScene
@export var tower_scene2: PackedScene
@export var tower_scene3: PackedScene
@export var tower_scene4: PackedScene
@export var tower_scene5: PackedScene
var tower_preview: Node3D = null
var rotating: bool = false
var target_zoom: float
var current_pitch: float = 0.0
var can_place_tower = not tower_preview or not tower_preview.visible
var blocked_tiles = [4, 5, 6, 9, 10, 12, 13, 14, 15, 16, 17, 18, 21, 22, 23, 24, 28, 29, 30, 31, 32, 42]

@onready var grid_map = $"../GridLower"
@onready var grid_main = $"../GridMain"
@onready var gridmid = $"../Gridmid"

func _ready():
	target_zoom = 6  # Start zoom
	current_pitch = rotation_degrees.x  # Store initial pitch
	tower_amount_lb.text = "x" + str(Global.placement_left) # update the remeaining towers

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



func create_tower_preview():
	if tower_scene1 and Global.placement_left > 0:
		tower_preview = tower_scene1.instantiate()
		add_child(tower_preview)
		tower_preview.process_mode = Node.PROCESS_MODE_DISABLED  # Disable physics for preview
	elif tower_scene2 and Global.placement_left > 0:
		tower_preview = tower_scene2.instantiate()
		add_child(tower_preview)
		tower_preview.process_mode = Node.PROCESS_MODE_DISABLED  # Disable physics for preview
	elif tower_scene3 and Global.placement_left > 0:
		tower_preview = tower_scene3.instantiate()
		add_child(tower_preview)
		tower_preview.process_mode = Node.PROCESS_MODE_DISABLED  # Disable physics for preview
	elif tower_scene4 and Global.placement_left > 0:
		tower_preview = tower_scene4.instantiate()
		add_child(tower_preview)
		tower_preview.process_mode = Node.PROCESS_MODE_DISABLED  # Disable physics for preview
	elif tower_scene5 and Global.placement_left > 0:
		tower_preview = tower_scene5.instantiate()
		add_child(tower_preview)
		tower_preview.process_mode = Node.PROCESS_MODE_DISABLED  # Disable physics for preview
	else:
		return
		# Make the preview transparent
		var mesh_instance = tower_preview.get_node_or_null("MeshInstance3D")
		if mesh_instance:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(1, 1, 1, 0.9)  # Semi-transparent
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mesh_instance.set_surface_override_material(0, mat)

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


func _physics_process(delta):
	# Smoothly interpolate towards the target zoom
	Global.placement_left = Global.placement_max - Global.placement_current
	tower_amount_lb.text = "x" + str(Global.placement_left)

	spring_arm.spring_length = lerp(spring_arm.spring_length, target_zoom, delta * zoom_smoothness)
	update_tower_position()
	if target_orbit_position:
		var current = orbit_pivot.global_transform.origin
		var new_pos = current.lerp(target_orbit_position, delta * 5)
		orbit_pivot.global_transform.origin = new_pos

func place_tower():
	if not tower_preview or not tower_preview.visible: # Disables the ability to place towers
		print("Can't place a tower here!") # if there is no collison surface by checking if the tower is invisible
		return

	if Global.placement_current >= Global.placement_max:
		print("max towers placed")
		return

	if tower_scene1 and tower_preview:
		var new_tower = tower_scene1.instantiate()
		get_parent().add_child(new_tower)
		new_tower.global_transform.origin = tower_preview.global_transform.origin
		Global.placement_current += 1
		print("tower placed1")

	if tower_scene2 and tower_preview:
		var new_tower = tower_scene2.instantiate()
		get_parent().add_child(new_tower)
		new_tower.global_transform.origin = tower_preview.global_transform.origin
		Global.placement_current += 1
		print("tower placed")

	if tower_scene3 and tower_preview:
		var new_tower = tower_scene3.instantiate()
		get_parent().add_child(new_tower)
		new_tower.global_transform.origin = tower_preview.global_transform.origin
		Global.placement_current += 1
		print("tower placed")

	if tower_scene4 and tower_preview:
		var new_tower = tower_scene4.instantiate()
		get_parent().add_child(new_tower)
		new_tower.global_transform.origin = tower_preview.global_transform.origin
		Global.placement_current += 1
		print("tower placed")

	if tower_scene5 and tower_preview:
		var new_tower = tower_scene5.instantiate()
		get_parent().add_child(new_tower)
		new_tower.global_transform.origin = tower_preview.global_transform.origin
		Global.placement_current += 1
		print("tower placed")

func _on_activity_but_button_down():
	create_tower_preview()

func _on_activity_but_button_up():
	place_tower()
	Global.placement_left = Global.placement_max - Global.placement_current
	tower_amount_lb.text = "x" + str(Global.placement_left)
	print(Global.placement_left)
	if not tower_preview==null:
		tower_preview.queue_free()

func _on_activity_but2_button_down():
	create_tower_preview()

func _on_activity_but2_button_up():
	place_tower()
	Global.placement_left = Global.placement_max - Global.placement_current
	tower_amount_lb.text = "x" + str(Global.placement_left)
	print(Global.placement_left)
	if not tower_preview==null:
		tower_preview.queue_free()

func _on_activity_but3_button_down():
	create_tower_preview()

func _on_activity_but3_button_up():
	place_tower()
	Global.placement_left = Global.placement_max - Global.placement_current
	tower_amount_lb.text = "x" + str(Global.placement_left)
	print(Global.placement_left)
	if not tower_preview==null:
		tower_preview.queue_free()

func _on_activity_but4_button_down():
	create_tower_preview()

func _on_activity_but4_button_up():
	place_tower()
	Global.placement_left = Global.placement_max - Global.placement_current
	tower_amount_lb.text = "x" + str(Global.placement_left)
	print(Global.placement_left)
	if not tower_preview==null:
		tower_preview.queue_free()

func _on_activity_but5_button_down():
	create_tower_preview()

func _on_activity_but5_button_up():
	place_tower()
	Global.placement_left = Global.placement_max - Global.placement_current
	tower_amount_lb.text = "x" + str(Global.placement_left)
	print(Global.placement_left)
	if not tower_preview==null:
		tower_preview.queue_free()
