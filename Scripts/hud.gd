extends Control

@onready var money: Label = $HBoxContainer/Money
@onready var wave: Label = $VBoxContainer/Wave
@onready var lives: Label = $VBoxContainer/Lives

func _physics_process(delta):
	lives.text = "Lives: " + str(Global.base_health)
	wave.text = "Wave: " + str(Global.current_wave)
	money.text = "$" + str(Global.player_money)
#de0000
