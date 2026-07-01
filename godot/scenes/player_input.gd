extends Node

var input_direction

func _ready() -> void:
	set_physics_process(false)
	NetworkTime.before_tick_loop.connect(_gather)
	
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)


func _gather() -> void:
	if not is_multiplayer_authority():
		return
	input_direction = Input.get_axis("move_left", "move_right")


@onready var player = $".."


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
	if Input.is_action_just_pressed("attack"):
		attack.rpc()
	


@rpc("call_local")
func jump():
	if multiplayer.is_server():
		player.do_jump = true

@rpc("call_local")
func attack():
	if multiplayer.is_server():
		player.attack = true
