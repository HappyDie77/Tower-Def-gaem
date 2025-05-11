extends CanvasLayer

@onready var start_scren = $"."

func _on_start_game_pressed():
	Global.button_pres = true
	queue_free()
