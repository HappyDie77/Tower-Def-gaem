extends CharacterBody3D

@export var speed: float = 0.3
@export var health: int = 180

@onready var path : PathFollow3D = get_parent()

func _physics_process(delta):
	path.set_progress(path.get_progress() + speed * delta)

	if path.get_progress_ratio() >= 0.99:
		Global.base_health -= 1
		path.queue_free()
func take_damage(damage: int) -> void:
	health -= damage
	
	if health <= 0:
		Global.player_money += 672
		queue_free()
