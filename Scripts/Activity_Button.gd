extends Button

@export var activity_button_icon:Texture2D
@export var activity_draggable:PackedScene
var is_drag:bool = false
var _draggable:Node

func _ready():
	icon = activity_button_icon
	_draggable = activity_draggable.instantiate()
	add_child(_draggable)
	_draggable.visible = false
func _on_button_down():
	is_drag = true 

func _on_button_up():
	is_drag = false
