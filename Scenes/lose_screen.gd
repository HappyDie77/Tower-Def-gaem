extends Control


@onready var total_kills: Label = $"ColorRect/Panel/VBoxContainer/Total Kills"
@onready var enemy_passed: Label = $"ColorRect/Panel/VBoxContainer/enemy passed"
@onready var towers_placed: Label = $"ColorRect/Panel/VBoxContainer/towers placed"
@onready var total_kills_2: Label = $"ColorRect/Panel/VBoxContainer2/Total Kills2"
@onready var enemy_passed_2: Label = $"ColorRect/Panel/VBoxContainer2/enemy passed2"
@onready var towers_placed_2: Label = $"ColorRect/Panel/VBoxContainer2/towers placed2"


func _ready() -> void:
	total_kills.text = "Total Kills: " + str(Global.enemies_killed)
	enemy_passed.text = "Total Enemies Leaked: " + str(Global.enemies_leaked)
	towers_placed.text = "Towers Placed: " + str(Global.towers_placed)
	total_kills_2.text = "Total Upgrades: " + str(Global.towers_upgraded)
	enemy_passed_2.text = "Towers Sold: " + str(Global.towers_sold)
	towers_placed_2.text = "Bosses Killed: " + str(Global.bosses_killed)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main Menu.tscn")
