extends Node3D

@onready var tower_1: CharacterBody3D = $"."

@onready var upg_scre = $Upg_scre
@onready var target: Button = $Upg_scre/Panel/VBoxContainer/Target
@onready var sell: Button = $Upg_scre/Panel/VBoxContainer2/Sell
@onready var upgrade: Button = $Upg_scre/Panel/VBoxContainer3/Upgrade
@onready var shoot_timer: Timer = $ShootTimer

@onready var atk_lb: Label = $Upg_scre/Panel2/VBoxContainer5/ATK_lb
@onready var range_lb: Label = $Upg_scre/Panel2/VBoxContainer5/Range_lb
@onready var spa_lb: Label = $Upg_scre/Panel2/VBoxContainer5/SPA_lb
@onready var tower_amount_lb_1 = $ActivityBut/Tower_amount_lb_1
@onready var tower_amount_lb_2: Label = $ActivityBut2/Tower_amount_lb_2

@onready var mob_shape: CollisionShape3D = $"Mob Detect/Mob Shape"
@onready var range_view: MeshInstance3D = $"Range view"

var cylinder_shape: CylinderShape3D
var cylinder: CylinderMesh

var Tower1_Upg_1: int = 560
var Tower1_Upg_2: int = 1450
var Tower1_Upg_3: int = 2560
var tower1_prices = [560, 1450, 2560]
var tower1_damage = [5, 8, 12, 15]
var tower1_SPA = [1.2, 1.2, 1]
var tower1_range = [1.5, 2, 2.2]

var muscuk=false
var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
var bullet_damage: int = 5
var current_targets: Array = []
var curr: CharacterBody3D
var can_shoot: bool = true
var new_radius: float = 1.5
var new_timer: float = 1.5
enum TargetMode { First, Closest, Last }
var target_mode: int = TargetMode.First
var current_dmg_now = 0

var duplicated_mesh: CylinderMesh
var duplicated_shape: CylinderShape3D

var mode_names = {
	TargetMode.First: "First",
	TargetMode.Last: "Last",
	TargetMode.Closest: "Closest"
}
var current_mode_name = mode_names[target_mode]

var in_cli=false

func _ready() -> void:
	add_to_group("towers")

	# Duplicate and assign unique shape
	var duplicated_shape = (mob_shape.shape as CylinderShape3D).duplicate(true)
	mob_shape.shape = duplicated_shape
	cylinder_shape = duplicated_shape  # now this points to the correct shape

	# Duplicate and assign unique mesh
	var duplicated_mesh = (range_view.mesh as CylinderMesh).duplicate(true)
	range_view.mesh = duplicated_mesh
	cylinder = duplicated_mesh  # now this points to the correct mesh

	$"Upg_scre/Panel/Dice buff".visible = false

	target.text = "" + mode_names[target_mode]
	upgrade.text = "$" + str(Tower1_Upg_1)
	atk_lb.text = "ATK: " + format_number(current_dmg_now)

	spa_lb.text = "SPA: " + str(new_timer)
	range_lb.text = "Range: " + str(new_radius)
	shoot_timer.wait_time = new_timer
	cylinder_shape.radius = new_radius * 2
	cylinder.top_radius = new_radius
	range_view.mesh = cylinder
	sell.text = "$" + str(sell_value)
	
	apply_global_buff()

func format_number(value: float) ->String:
	if int(value) == value:
		return str(int(value))
	elif (value * 10) == floor(value * 10):
		return "%0.1f" % value
	else:
		return "%0.2f" % value

var upgrade_level = 0
var upgrades = tower1_prices
var damage = tower1_damage
var Spa_time = tower1_SPA
var range_rad = tower1_range
var sell_value = 0
var dmg_inc = damage[0]
var spa_inc = Spa_time[0]
var range_inc = range_rad[0]

func _process(delta):
	if Input.is_action_just_pressed("Buy"):
		_on_upgrade_pressed()
	elif Input.is_action_just_pressed("Sell"):
		_on_sell_pressed()
	elif Input.is_action_just_pressed("Change Target"):
		_on_target_pressed()
	
	if is_instance_valid(curr):
		var target_pos = curr.global_position
		target_pos.y = global_transform.origin.y  # Match Y so it won't look up/down
		look_at(target_pos)

		if can_shoot:
			shoot()
			can_shoot = false
			$ShootTimer.start()

	else:
		for i in get_node("BulletContainer").get_child_count():
			get_node("BulletContainer").get_child(i).queue_free()

	if Input.is_action_just_pressed("Left Click") and in_cli:
		range_view.visible = !range_view.visible
		upg_scre.visible = !upg_scre.visible
	elif Input.is_action_just_pressed("Left Click"):
		if not muscuk :
			range_view.visible = false
			upg_scre.visible = false

func apply_global_buff():
	current_dmg_now = damage[upgrade_level] * Global.buff_multiplier
	atk_lb.text = "ATK: " + format_number(current_dmg_now)
	if Global.buff_tower_placed:
		$Upg_scre/Panel/Status_buff.visible = true
		$"Upg_scre/Panel/Dice buff".visible = true

func shoot() -> void:
	var temp_bullet: CharacterBody3D = bullet.instantiate()
	temp_bullet.target = curr
	temp_bullet.bullet_damage = current_dmg_now
	get_node("BulletContainer").add_child(temp_bullet)
	temp_bullet.global_position = $Towermesh/Aim.global_position

func choose_target(_current_targets: Array) -> void:
	var temp_array: Array = _current_targets
	var current_target : CharacterBody3D = null
	for i in temp_array:
		if current_target == null:
			current_target = i
		elif target_mode == TargetMode.First:
			if i.get_parent().get_progress() > current_target.get_parent().get_progress():
				current_target = i
		elif target_mode == TargetMode.Last:
			if i.get_parent().get_progress() < current_target.get_parent().get_progress():
				current_target = i
		elif target_mode == TargetMode.Closest:
			if i.global_transform.origin.distance_to(global_transform.origin) < current_target.global_transform.origin.distance_to(global_transform.origin):
				current_target = i
	curr = current_target
	
func _on_mob_detect_body_entered(body):
	if body.is_in_group("Enemygro"):
		current_targets.append(body)
		choose_target(current_targets)

func _on_mob_detect_body_exited(body):
	if body.is_in_group("Enemygro"):
		current_targets.erase(body)
		choose_target(current_targets)

func _on_shoot_timer_timeout():
	can_shoot = true


func _on_tower_click_mouse_entered():
	in_cli=true


func _on_tower_click_mouse_exited():
	in_cli=false

func _on_t_ouch_mouse_entered():
	print("work")
	muscuk = true


func _on_t_ouch_mouse_exited():
	print("out")
	muscuk = false

func _on_upgrade_pressed():
	if not upg_scre.visible:
		return  # Only respond if this tower's UI is active

	if upgrade_level >= upgrades.size():
		atk_lb.text = "ATK: " + format_number(current_dmg_now)

		spa_lb.text = "SPA: " + str(new_timer)
		sell.text = "$" + str(sell_value)
		range_lb.text = "Range: " + str(new_radius)
		upgrade.text = "MAX"
		return

	var cost = upgrades[upgrade_level]
	if Global.player_money >= cost:
		$Buy.play()
		Global.player_money -= cost
		Global.towers_upgraded += 1
		sell_value = cost / 2
		upgrade_level += 1
		new_timer = spa_inc
		shoot_timer.wait_time = new_timer
		new_radius = range_inc
		cylinder_shape.radius = new_radius * 2
		cylinder.top_radius = new_radius
		apply_global_buff()

		# Set new damage based on new upgrade level
		if upgrade_level < damage.size():
			dmg_inc = damage[upgrade_level]
		else:
			dmg_inc = damage[-1]  # Max damage

		if upgrade_level < Spa_time.size():
			spa_inc = Spa_time[upgrade_level]
		else:
			spa_inc = Spa_time[1]

		if upgrade_level < range_rad.size():
			range_inc = range_rad[upgrade_level]
		else:
			range_inc = range_rad[-1] 

		if upgrade_level < upgrades.size():
			upgrade.text = "$" + str(upgrades[upgrade_level])
			atk_lb.text = "ATK: " + format_number(current_dmg_now)

			spa_lb.text = "SPA: " + str(new_timer)
			sell.text = "$" + str(sell_value)
			range_lb.text = "Range: " + str(new_radius)
		else:
			atk_lb.text = "ATK: " + format_number(current_dmg_now)

			spa_lb.text = "SPA: " + str(new_timer)
			sell.text = "$" + str(sell_value)
			range_lb.text = "Range: " + str(new_radius)
			upgrade.text = "MAX"
	else:
		print("Not enough money to upgrade.")

func _on_sell_pressed() -> void:
	if not upg_scre.visible:
		return  # Only respond if this tower's UI is active
	Global.placement_current[1] -= 1
	Global.placement_left[1] = Global.placement_max[1] - Global.placement_current[1]
	Global.player_money += sell_value
	Global.sell_true = true
	Global.towers_sold += 1
	tower_1.visible = false
	upg_scre.visible = false
	range_view.visible = false
	
	$Sell.play()

func _on_sell_finished() -> void:
	queue_free()


func _on_target_pressed() -> void:
	if upg_scre.visible:
		target_mode = TargetMode.values()[(target_mode + 1) % TargetMode.size()]
		target.text = "" + mode_names[target_mode]

func _on_area_2d_mouse_entered() -> void:
	$Upg_scre/Panel3.visible = true

func _on_area_2d_mouse_exited() -> void:
	$Upg_scre/Panel3.visible = false

func _on_atk_spd_mouse_entered() -> void:
	$"Upg_scre/ATK SPD".visible = true

func _on_atk_spd_mouse_exited() -> void:
	$"Upg_scre/ATK SPD".visible = false

func _on_target_type_mouse_entered() -> void:
	$Upg_scre/TARGET_TYPE.visible = true

func _on_target_type_mouse_exited() -> void:
	$Upg_scre/TARGET_TYPE.visible = false

func _on_effect_trype_mouse_entered() -> void:
	$Upg_scre/EFFECT_TYPE.visible = true

func _on_effect_trype_mouse_exited() -> void:
	$Upg_scre/EFFECT_TYPE.visible = false
