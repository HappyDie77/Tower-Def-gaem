extends Node

@onready var upgrade = $Upg_scre/Panel/VBoxContainer3/Upgrade

# In Global.gd
var placement_max = {
	1: 3,
	2: 2,
	3: 1,
	4: 1,
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

var buff_multiplier: float = 1.0
var buff_tower_placed: bool = false


func _ready():
	for i in placement_max.keys():
		placement_left[i] = placement_max[i] - placement_current[i]

var base_health = 10

var button_pres = false

var player_money = 0

var current_wave = 0

var wave_started = false

var sell_true = null


var bosses_killed = 0
var enemies_killed = 0
var towers_placed = 0
var towers_sold = 0
var enemies_leaked = 0
var towers_upgraded = 0
