extends Node3D
#VFX vid
#https://www.youtube.com/watch?v=74XywaLGO5Q

@onready var ost_1: AudioStreamPlayer = $"Ost 1"
@export var Instance = preload("res://Scenes/settings_menu_Instantiate.tscn")
@onready var wave_update = $Wave_update
@export var Lose_hlt = preload("res://Scenes/lose_screen.tscn")

var current_wave: int = 0
var enemeies_alive: int = 0
var can_spawn: bool = false
var first_wave_complete = false

func _ready() -> void:
	Global.base_health = 10
	Global.placement_current = {
	1: 0,
	2: 0,
	3: 0,
	4: 0,
	5: 0
}

var enemy_types = {
	"coconut": preload("res://Scenes/Enemies/coco.tscn"),
	"jungle": preload("res://Scenes/Enemies/jungle.tscn"),
	"crab": preload("res://Scenes/Enemies/crab.tscn"),
	"idol boss": preload("res://Scenes/Enemies/idol.tscn")
}

var wave_1 = [
	{
		"enemies": {
			"coconut": 0,
		},
		"delay_after": 2.0
	},
	{
		"enemies": {
			"coconut": 10,
			"jungle": 4
		},
		"delay_after": 10.0
	},
	{
		"enemies": {
			"coconut": 10,
			"jungle": 4
		},
		"delay_after": 10.0
	}
]

var wave_2 = [
	{
		"enemies": {
			"jungle": 10
		},
		"delay_after": 12.0
	},
	{
		"enemies": {
			"coconut": 10,
			"crab": 1
		},
		"delay_after": 10.0
	},
	{
		"enemies": {
			"coconut": 4,
			"jungle": 6
		},
		"delay_after": 12.0
	}
]

var wave_3 = [
	{
		"enemies": {
			"coconut": 20
		},
		"delay_after": 12.0
	},
	{
		"enemies": {
			"crab": 4
		},
		"delay_after": 12.0
	},
	{
		"enemies": {
			"jungle": 8,
			"crab": 2
		},
		"delay_after": 8.0
	}
]

var wave_4 = [
	{
		"enemies": {
			"jungle": 15,
			"crab": 2,
			"coconut": 5
		},
		"delay_after": 12.0
	},
	{
		"enemies": {
			"jungle": 8,
			"crab": 2
		},
		"delay_after": 12.0
	}
]

var wave_5 = [
	{
		"enemies": {
			"crab": 3,
			"jungle": 2,
		},
		"delay_after": 12.0
	},
	{
		"enemies": {
			"coconut": 4,
			"crab": 6,
			"idol boss": 1
		},
		"delay_after": 10.0
	}
]

var current_wave_index := 0
var all_waves: Array = [wave_1, wave_2, wave_3, wave_4, wave_5] # etc.

func spawn_wave(wave_sections: Array) -> void:
	Global.player_money += 560
	print("=== Wave Started! ===")
	Global.wave_started = true
	for section in wave_sections:
		var enemies_dict = section["enemies"]
		for enemy_name in enemies_dict.keys():
			var count = enemies_dict[enemy_name]
			var scene = enemy_types[enemy_name]
			for i in range(count):
				var enemy = scene.instantiate()
				$Path.add_child(enemy)
				print("Spawned %s (%d/%d)" % [enemy_name, i+1, count])
				await $SpawnTimer.timeout
		var d = section["delay_after"]
		if d > 0.0:
			print("Waiting %.1f seconds before next section…" % d)
			await get_tree().create_timer(d).timeout
	print("=== Wave complete! ===")

func start_all_waves():
	if current_wave_index >= all_waves.size():
		print("All waves completed!")
		return

	while current_wave_index < all_waves.size():
		await spawn_wave(all_waves[current_wave_index])
		current_wave_index += 1
		if current_wave_index == 0:
			wave_update.text = "Wave %d Is Starting" % (current_wave_index + 1)
			wave_update.visible = true
			await get_tree().create_timer(4).timeout
			wave_update.visible = false
		if current_wave_index == 1:
			wave_update.text = "Wave %d Is Starting" % (current_wave_index + 1)
			$Wave_complete.play()
			wave_update.visible = true
			await get_tree().create_timer(4).timeout
			wave_update.visible = false
		if current_wave_index == 2:
			wave_update.text = "Wave %d Is Starting" % (current_wave_index + 1)
			$Wave_complete.play()
			wave_update.visible = true
			await get_tree().create_timer(4).timeout
			wave_update.visible = false
		if current_wave_index == 3:
			wave_update.text = "Wave %d Is Starting" % (current_wave_index + 1)
			$Wave_complete.play()
			wave_update.visible = true
			await get_tree().create_timer(4).timeout
			wave_update.visible = false
		if current_wave_index == 4:
			wave_update.text = "Wave %d Is Starting" % (current_wave_index + 1)
			$Wave_complete.play()
			wave_update.visible = true
			await get_tree().create_timer(4).timeout
			wave_update.visible = false
	start_all_waves()

func _process(delta):
	if Global.button_pres:
		#Global.player_money += 560
		$Wave_complete.play()
		Global.current_wave += 1
		start_all_waves()
		Global.button_pres = false
	
	if Global.base_health == 0:
		get_tree().change_scene_to_file("res://Scenes/lose_screen.tscn")

#var wave_1 = {"slime": 5}
#spawn_wave(wave_1)  # sends it in

#func spawn_wave(wave_dict):  # wave_dict now = {"slime": 5}
	#for enemy_type in wave_dict:
	   # var count = wave_dict[enemy_type]
	   # print("Spawning", count, enemy_type)


func _on_settings_pressed() -> void:
	get_tree().paused
	$Hud.visible = false
	if $Start_screen:
		$Start_screen.visible = false
	var Temp_sett = Instance.instantiate()
	Temp_sett.hud = $Hud
	Temp_sett.start_screen = $Start_screen
	add_child(Temp_sett)
