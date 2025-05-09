extends CanvasLayer

@onready var start_scren = $"."

func _on_start_game_pressed():
	start_scren.visible = false
	Global.button_pres = true
