extends CharacterBody3D

@export var speed: int = 2
@export var health: int = 10

@onready var path : PathFollow3D = get_parent()

func _physics_process(delta):
	path.set_progress(path.get_progress() + speed * delta)

	if path.get_progress_ratio() >= 0.99:
		path.queue_free()
