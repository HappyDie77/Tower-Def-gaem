extends Node

@onready var upgrade = $Upg_scre/Panel/VBoxContainer3/Upgrade

# In Global.gd
var placement_max = {
	1: 3,
	2: 3,
	3: 3,
	4: 3,
	5: 3
}
var placement_current = {
	1: 0,
	2: 0,
	3: 0,
	4: 0,
	5: 0
}
var placement_left = {}

func _ready():
	for i in placement_max.keys():
		placement_left[i] = placement_max[i] - placement_current[i]

var base_health = 10

var button_pres = false

var player_money = 10000

var current_wave = 0

var Tower1_Upg_1: int = 560
var Tower1_Upg_2: int = 1450
var Tower1_Upg_3: int = 2560
var tower1_prices = [560, 1450, 2560]
var tower1_damage = [5, 8, 12, 15]
var tower1_SPA = [1.2, 1.2, 1]
var tower1_range = [1.5, 2, 2.2]

var Tower2_Upg_1: int = 865
var Tower2_Upg_2: int = 1940
var Tower2_Upg_3: int = 4235
var tower2_prices = [865, 1940, 4235]
var tower2_damage = [4, 7.2, 9, 12.5]
var tower2_SPA = [2.8, 2.4, 2.2] 
var tower2_range = [1.8, 2, 2.2]

var Tower3_Upg_1: int = 560
var Tower3_Upg_2: int = 1450
var Tower3_Upg_3: int = 2560
var tower3_prices = [560, 1450, 2560]
var tower3_damage = [5, 8, 12, 15]
var tower3_SPA = [1.2, 1.2, 1]
var tower3_range = [1.5, 2, 2.2]

var Tower4_Upg_1: int = 560
var Tower4_Upg_2: int = 1450
var Tower4_Upg_3: int = 2560
var tower4_prices = [560, 1450, 2560]
var tower4_damage = [5, 8, 12, 15]
var tower4_SPA = [1.2, 1.2, 1]
var tower4_range = [1.5, 2, 2.2]

var Tower5_Upg_1: int = 560
var Tower5_Upg_2: int = 1450
var Tower5_Upg_3: int = 2560
var tower5_prices = [560, 1450, 2560]
var tower5_damage = [5, 8, 12, 15]
var tower5_SPA = [1.2, 1.2, 1]
var tower5_range = [1.5, 2, 2.2]
var sell_true = null
