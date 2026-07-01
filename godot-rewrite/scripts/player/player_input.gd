class_name PlayerInput
extends Node


var input_dir: float
var input_jump = 0


func _ready() -> void:
	set_physics_process(false)
	NetworkTime.before_tick_loop.connect(_gather)


func _gather() -> void:
	if not is_multiplayer_authority():
		return
	
	if multiplayer.has_multiplayer_peer():
		input_dir = Input.get_axis("left", "right")


func _process(delta):
	input_jump = Input.get_action_strength("jump")
