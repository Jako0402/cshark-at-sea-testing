extends MultiplayerSynchronizer

var input_direction
@onready var player = $".."


func _ready() -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
	input_direction = Input.get_axis("move_left", "move_right")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
	if Input.is_action_just_pressed("attack"):
		attack.rpc()
	
func _physics_process(delta: float) -> void:
	input_direction = Input.get_axis("move_left", "move_right")

@rpc("call_local")
func jump():
	if multiplayer.is_server():
		player.do_jump = true

@rpc("call_local")
func attack():
	if multiplayer.is_server():
		player.attack = true
