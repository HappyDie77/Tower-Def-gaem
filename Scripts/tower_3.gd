extends Node3D

@onready var tower_3: CharacterBody3D = $"."

@onready var upg_scre = $Upg_scre
@onready var target: Button = $Upg_scre/Panel/VBoxContainer/Target
@onready var sell: Button = $Upg_scre/Panel/VBoxContainer2/Sell
@onready var upgrade: Button = $Upg_scre/Panel/VBoxContainer3/Upgrade
@onready var shoot_timer: Timer = $ShootTimer

@onready var atk_lb: Label = $Upg_scre/Panel2/VBoxContainer5/ATK_lb
@onready var range_lb: Label = $Upg_scre/Panel2/VBoxContainer5/Range_lb
@onready var spa_lb: Label = $Upg_scre/Panel2/VBoxContainer5/SPA_lb
@onready var face_1: Label = $"Upg_scre/Panel3/Face 1"
@onready var face_2: Label = $"Upg_scre/Panel3/Face 2"
@onready var face_3: Label = $"Upg_scre/Panel3/Face 3"
@onready var face_4: Label = $"Upg_scre/Panel3/Face 4"
@onready var face_5: Label = $"Upg_scre/Panel3/Face 5"
@onready var face_6: Label = $"Upg_scre/Panel3/Face 6"
@onready var curr_buff: Label = $"Upg_scre/Panel5/Curr buff"
@onready var uable_to_sell: Label = $"Uable to sell"

@onready var mob_shape: CollisionShape3D = $"Mob Detect/Mob Shape"
@onready var range_view: MeshInstance3D = $"Range view"

var cylinder_shape: CylinderShape3D
var cylinder: CylinderMesh

var muscuk=false
var current_targets: Array = []
var can_shoot: bool = true
var new_radius: float = 1
var new_timer: float = 1.5
enum TargetMode { First, Closest, Last }
var target_mode: int = TargetMode.First

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
	randomize()
	var result = dice_roll()
	var result_pros = tower3_dice_buffs[result]
	# Duplicate and assign unique shape
	var duplicated_shape = (mob_shape.shape as CylinderShape3D).duplicate(true)
	mob_shape.shape = duplicated_shape
	cylinder_shape = duplicated_shape  # now this points to the correct shape

	# Duplicate and assign unique mesh
	var duplicated_mesh = (range_view.mesh as CylinderMesh).duplicate(true)
	range_view.mesh = duplicated_mesh
	cylinder = duplicated_mesh  # now this points to the correct mesh

	target.text = "" + mode_names[target_mode]
	upgrade.text = "$" + str(Tower3_Upg_1)
	atk_lb.text = "ATK: " + str(dmg_inc)
	spa_lb.text = "SPA: " + str(new_timer)
	face_1.text = "1: " + str(round(tower3_dice_chances[1] * 100)) + "%"
	face_2.text = "2: " + str(round(tower3_dice_chances[2] * 100)) + "%"
	face_3.text = "3: " + str(round(tower3_dice_chances[3] * 100)) + "%"
	face_4.text = "4: " + str(round(tower3_dice_chances[4] * 100)) + "%"
	face_5.text = "5: " + str(round(tower3_dice_chances[5] * 100)) + "%"
	face_6.text = "6: " + str(round(tower3_dice_chances[6] * 100)) + "%"
	range_lb.text = "Range: " + str(new_radius)
	shoot_timer.wait_time = new_timer
	cylinder_shape.radius = new_radius * 2
	cylinder.top_radius = new_radius
	range_view.mesh = cylinder

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Buy"):
		_on_upgrade_pressed()
	elif Input.is_action_just_pressed("Change Target"):
		_on_target_pressed()

	if Input.is_action_just_pressed("Left Click") and in_cli:
		range_view.visible = !range_view.visible
		upg_scre.visible = !upg_scre.visible
	elif Input.is_action_just_pressed("Left Click"):
		if not muscuk :
			range_view.visible = false
			upg_scre.visible = false


	if Global.wave_started:
		var result = dice_roll()
		var result_pros = tower3_dice_buffs[result]
		curr_buff.text = "ATK " + str(result_pros) + "%"
		$"Buff sound".play()
		Global.buff_tower_placed = true
		print("Before update: ", Global.buff_multiplier)
		Global.buff_multiplier = 1.0 + result_pros / 100.0
		print("After update: ", Global.buff_multiplier)
		for node in get_tree().get_nodes_in_group("towers"):
			print("Applying buff to: ", node)
			if node.has_method("apply_global_buff"):
				node.apply_global_buff()
			else:
				print("Node doesn't have apply_global_buff:", node)
		Global.wave_started = false

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


var Tower3_Upg_1: int = 1640
var Tower3_Upg_2: int = 3520
var Tower3_Upg_3: int = 7820
var tower3_prices = [1640, 3520, 7820]
var tower3_damage = [0, 0, 0, 0]
var tower3_dice_faces = [1, 2, 3, 4, 5, 6]
var tower3_dice_chances = {
	1: 0.08,
	2: 0.12,
	3: 0.30,
	4: 0.40,
	5: 0.08,
	6: 0.02
}
var tower3_dice_upgrades = [
	{2: -0.04, 5: 0.02, 3: -0.06, 4: 0.08},   # 	Upgrade_lvl_1		Upgrade level 0 → Increase face 1, decrease face 6
	{6: 0.06, 3: -0.03, 1: -0.02, 4: -0.04, 5: 0.03},              # 	Upgrade_lvl_2		Upgrade level 1 → Increase face 2
	{6: 0.09, 3: -0.06, 5: 0.12, 4: -0.15}      # 	Upgrade_lvl_3		Upgrade level 2 → More to 3, less from 5
]
var tower3_dice_buffs = {
	1: -25,
	2: -15,
	3: 0,
	4: 15,
	5: 35,
	6: 50
}
var tower3_SPA = [0, 0, 0]
var tower3_range = [1, 1, 1]

var upgrade_level = 0
var upgrades = tower3_prices
var damage = tower3_damage
var Spa_time = tower3_SPA
var range_rad = tower3_range
var dice_face_roll = tower3_dice_upgrades
var sell_value = 0
var dmg_inc = damage[0]
var spa_inc = Spa_time[0]
var range_inc = range_rad[0]
var roll_inc = dice_face_roll[0]

func dice_roll():
	var rolled = randf()
	var acumalit = 0
	for face in tower3_dice_chances.keys():
		acumalit += tower3_dice_chances[face]
		if rolled <= acumalit:
			return face

func _on_upgrade_pressed():
	if not upg_scre.visible:
		return  # Only respond if this tower's UI is active

	if upgrade_level >= upgrades.size():
		atk_lb.text = "ATK: " + str(dmg_inc)
		face_1.text = "1: " + str(round(tower3_dice_chances[1] * 100)) + "%"
		face_2.text = "2: " + str(round(tower3_dice_chances[2] * 100)) + "%"
		face_3.text = "3: " + str(round(tower3_dice_chances[3] * 100)) + "%"
		face_4.text = "4: " + str(round(tower3_dice_chances[4] * 100)) + "%"
		face_5.text = "5: " + str(round(tower3_dice_chances[5] * 100)) + "%"
		face_6.text = "6: " + str(round(tower3_dice_chances[6] * 100)) + "%"
		spa_lb.text = "SPA: " + str(new_timer)
		
		range_lb.text = "Range: " + str(new_radius)
		upgrade.text = "MAX"
		return

	var cost = upgrades[upgrade_level]
	if Global.player_money >= cost:
		$Buy.play()
		Global.player_money -= cost
		sell_value = cost / 2
		upgrade_level += 1
		Global.towers_upgraded += 1
		new_timer = spa_inc
		shoot_timer.wait_time = new_timer
		new_radius = range_inc
		cylinder_shape.radius = new_radius * 2
		cylinder.top_radius = new_radius

		# Set new damage based on new upgrade level
		if upgrade_level < damage.size():
			dmg_inc = damage[upgrade_level]
		else:
			dmg_inc = damage[-1]  # Max damage

		if upgrade_level < Spa_time.size():
			spa_inc = Spa_time[upgrade_level]
		else:
			spa_inc = Spa_time[-1]
		
		if upgrade_level - 1 < tower3_dice_upgrades.size():
			roll_inc = dice_face_roll[upgrade_level - 1]
			for i in roll_inc:
				tower3_dice_chances[i] += roll_inc[i]
		else:
			roll_inc = dice_face_roll[-1]
		
		if upgrade_level < range_rad.size():
			range_inc = range_rad[upgrade_level]
		else:
			range_inc = range_rad[-1] 

		if upgrade_level < upgrades.size():
			print(tower3_dice_chances)
			upgrade.text = "$" + str(upgrades[upgrade_level])
			face_1.text = "1: " + str(round(tower3_dice_chances[1] * 100)) + "%"
			face_2.text = "2: " + str(round(tower3_dice_chances[2] * 100)) + "%"
			face_3.text = "3: " + str(round(tower3_dice_chances[3] * 100)) + "%"
			face_4.text = "4: " + str(round(tower3_dice_chances[4] * 100)) + "%"
			face_5.text = "5: " + str(round(tower3_dice_chances[5] * 100)) + "%"
			face_6.text = "6: " + str(round(tower3_dice_chances[6] * 100)) + "%"
			atk_lb.text = "ATK: " + str(dmg_inc)
			spa_lb.text = "SPA: " + str(new_timer)
			
			range_lb.text = "Range: " + str(new_radius)
		else:
			atk_lb.text = "ATK: " + str(dmg_inc)
			spa_lb.text = "SPA: " + str(new_timer)
			face_1.text = "1: " + str(round(tower3_dice_chances[1] * 100)) + "%"
			face_2.text = "2: " + str(round(tower3_dice_chances[2] * 100)) + "%"
			face_3.text = "3: " + str(round(tower3_dice_chances[3] * 100)) + "%"
			face_4.text = "4: " + str(round(tower3_dice_chances[4] * 100)) + "%"
			face_5.text = "5: " + str(round(tower3_dice_chances[5] * 100)) + "%"
			face_6.text = "6: " + str(round(tower3_dice_chances[6] * 100)) + "%"

			range_lb.text = "Range: " + str(new_radius)
			upgrade.text = "MAX"
	else:
		print("Not enough money to upgrade.")

func _on_sell_finished() -> void:
	queue_free()


func _on_target_pressed() -> void:
	if upg_scre.visible:
		target_mode = TargetMode.values()[(target_mode + 1) % TargetMode.size()]
		target.text = "" + mode_names[target_mode]

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
