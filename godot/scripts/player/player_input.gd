class_name PlayerInput
extends Node


var input_dir: float

var jump_held: bool = false
var jump_just_pressed: bool = false
var _previous_jump_held: bool = false

func _ready() -> void:
	set_physics_process(false)
	set_process(false)
	NetworkTime.before_tick_loop.connect(_gather)


func _gather() -> void:
	if not is_multiplayer_authority():
		return
	
	if multiplayer.has_multiplayer_peer():
		input_dir = Input.get_axis("left", "right")
		_previous_jump_held = jump_held
		jump_held = Input.is_action_pressed("jump")
		jump_just_pressed = jump_held and not _previous_jump_held
