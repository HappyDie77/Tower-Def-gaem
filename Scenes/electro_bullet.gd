extends CharacterBody3D


var target: CharacterBody3D
var speed: int = 12
var bullet_damage: int 

func _physics_process(delta):
	if is_instance_valid(target):
		velocity = global_position.direction_to(target.global_position) * speed
		look_at(target.global_position)
		
		move_and_slide()
	else:
		queue_free()

func _on_area_3d_body_entered(body):
	if body.is_in_group("Enemygro"):
		body.take_damage(bullet_damage)
		queue_free()
