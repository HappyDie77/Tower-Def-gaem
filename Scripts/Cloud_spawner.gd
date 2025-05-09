extends CSGBox3D


@export var clouds_to_spawn: int = 3
@export var cloud: PackedScene

func _ready():
	spawn_clouds()

var rng = RandomNumberGenerator.new()

func spawn_clouds():
	while clouds_to_spawn >= 0:
		clouds_to_spawn -= 1
		
		var x: float = rng.randf_range(size.x / 2, -size.x / 2)
		var y: float = rng.randf_range(size.y / 2, -size.y / 2)
		var z: float = rng.randf_range(size.z / 2, -size.z / 2)
		
		var spawn_pos: Vector3 = Vector3(x, y, z)
		
		var temp_cloud: = cloud.instantiate()
		add_child(temp_cloud)
		temp_cloud.global_position = self.global_position + spawn_pos
