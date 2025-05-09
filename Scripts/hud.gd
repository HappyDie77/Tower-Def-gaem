extends Control

@onready var lives = $CanvasLayer/HBoxContainer/Lives
@onready var wave = $CanvasLayer/HBoxContainer/Wave
@onready var money = $CanvasLayer/HBoxContainer/Money
@onready var hud = $"."

func _ready():
	hud.visible = false

func _physics_process(delta):
	lives.text = "Lives: " + str(Global.base_health)
	wave.text = "Wave: " + str(Global.current_wave)
	money.text = "$" + str(Global.player_money)
#de0000
