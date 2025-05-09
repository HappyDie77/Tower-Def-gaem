extends Node3D

var current_wave: int = 0
var enemeies_alive: int = 0
var can_spawn: bool = false

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
	},
	{
		"enemies": {
			"crab": 2,
			"idol boss": 1
		},
		"delay_after": 2.0
	}
]

func spawn_wave(wave_sections: Array) -> void:
	# for each section in order...
	for section in wave_sections:
		var enemies_dict = section["enemies"]
		# for each type in that section...
		for enemy_name in enemies_dict.keys():
			var count = enemies_dict[enemy_name]
			var scene = enemy_types[enemy_name]
			# your old for-i-in-range(count) loop, but now yielding on your SpawnTimer:
			for i in range(count):
				var enemy = scene.instantiate()
				$Path.add_child(enemy)
				print("Spawned %s (%d/%d)" % [enemy_name, i+1, count])
				# wait one timer tick before next spawn:
				await $SpawnTimer.timeout
		# after finishing this section, pause for its delay:
		var d = section["delay_after"]
		if d > 0.0:
			print("Waiting %.1f seconds before next section…" % d)
			await get_tree().create_timer(d).timeout
	print("=== Wave complete! ===")

func _process(delta):
	if Global.button_pres:
		Global.current_wave += 1
		spawn_wave(wave_1)
		Global.button_pres = false



#var wave_1 = {"slime": 5}
#spawn_wave(wave_1)  # sends it in

#func spawn_wave(wave_dict):  # wave_dict now = {"slime": 5}
	#for enemy_type in wave_dict:
	   # var count = wave_dict[enemy_type]
	   # print("Spawning", count, enemy_type)
