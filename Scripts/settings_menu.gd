extends Control


func _on_back_pressed():
	AudioServer.set_bus_volume_db(0, linear_to_db($CanvasLayer/Background/VBoxContainer/Master.value))
	AudioServer.set_bus_volume_db(1, linear_to_db($CanvasLayer/Background/VBoxContainer/Music.value))
	AudioServer.set_bus_volume_db(2, linear_to_db($CanvasLayer/Background/VBoxContainer/SFX.value))
	get_tree().change_scene_to_file("res://Scenes/Main Menu.tscn")

func _ready() -> void:
	$CanvasLayer/Background/VBoxContainer/Master.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	$CanvasLayer/Background/VBoxContainer/Music.value = db_to_linear(AudioServer.get_bus_volume_db(1))
	$CanvasLayer/Background/VBoxContainer/SFX.value = db_to_linear(AudioServer.get_bus_volume_db(2))



func _on_master_mouse_exited() -> void:
	release_focus()


func _on_music_mouse_exited() -> void:
	release_focus()


func _on_sfx_mouse_exited() -> void:
	release_focus()
