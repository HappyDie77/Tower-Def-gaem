extends Node

@onready var upgrade = $Upg_scre/Panel/VBoxContainer3/Upgrade

var placement_max: int = 3
var placement_current: int = 0
var placement_left = placement_max - placement_current

var base_health = 10

var button_pres = false

var player_money = 0

var current_wave = 0

var Tower1_current_upg = 0

var Tower1_Upg_1: int = 560
var Tower1_Upg_2: int = 1450
var Tower1_Upg_3: int = 2560

var sell = 0
