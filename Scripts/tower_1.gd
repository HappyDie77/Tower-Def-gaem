extends Node3D

@onready var range_view = $"Range view"
@onready var upg_scre = $Upg_scre
@onready var upgrade = $Upg_scre/Panel/VBoxContainer3/Upgrade
@onready var current_target = $CanvasLayer/Panel/VBoxContainer/Current_target



var muscuk=false

var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
var bullet_damage: int = 5
var current_targets: Array = []
var curr: CharacterBody3D
var can_shoot: bool = true


var in_cli=false

func _process(delta):
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
		if not muscuk:
			range_view.visible = false
			upg_scre.visible = false

func shoot() -> void:
	var temp_bullet: CharacterBody3D = bullet.instantiate()
	temp_bullet.target = curr
	temp_bullet.bullet_damage = bullet_damage
	get_node("BulletContainer").add_child(temp_bullet)
	temp_bullet.global_position = $Towermesh/Aim.global_position

func choose_target(_current_targets: Array) -> void:
	var temp_array: Array = _current_targets
	var current_target : CharacterBody3D = null
	for i in temp_array:
		if current_target == null:
			current_target = i
		else:
			if i.get_parent().get_progress() > current_target.get_parent().get_progress():
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
	# Choose the upgrade level and its cost
	Global.Tower1_current_upg = Global.Tower1_Upg_1  # You can change this to Upg_2 or _3 as needed

	if Global.player_money >= Global.Tower1_current_upg:
		Global.player_money -= Global.Tower1_current_upg  # Deduct the cost
		upgrade.text = "$" + str(Global.Tower1_current_upg)  # Update UI
		print("Upgrade successful!")
	else:
		print("Not enough money to upgrade.")
	
	Global.Tower1_current_upg = Global.Tower1_Upg_2
	upgrade.text = "$" + str(Global.Tower1_current_upg)
