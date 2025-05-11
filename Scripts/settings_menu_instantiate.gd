extends Control

var hud = null
var start_screen = null

func _on_back_pressed():
	hud.visible = true
	if start_screen:
		start_screen.visible = true
	queue_free()

func _ready() -> void:
	$Background/VBoxContainer/Master.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	$Background/VBoxContainer/Music.value = db_to_linear(AudioServer.get_bus_volume_db(1))
	$Background/VBoxContainer/SFX.value = db_to_linear(AudioServer.get_bus_volume_db(2))



func _on_master_mouse_exited() -> void:
	release_focus()


func _on_music_mouse_exited() -> void:
	release_focus()


func _on_sfx_mouse_exited() -> void:
	release_focus()

func _on_master_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db($Background/VBoxContainer/Master.value))


func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db($Background/VBoxContainer/Music.value))


func _on_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db($Background/VBoxContainer/SFX.value))
