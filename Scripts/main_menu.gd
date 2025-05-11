extends Control

@onready var banner_roll = $ColorRect/Banner/Banner_Roll

func _on_begin_pressed():
	banner_roll.play("Banner Roll")
	
	await $ColorRect/Banner/Timer_Roll.timeout


func _on_settings_pressed():
	get_tree().change_scene_to_file("res://Scenes/settings_menu.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_creds_pressed():
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")


func _on_banner_roll_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
