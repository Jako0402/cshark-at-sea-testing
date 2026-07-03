class_name Player
extends CharacterBody2D

const SPEED = 140.0
const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var rollback_synchronizer = $RollbackSynchronizer
@export var player_input: PlayerInput
@export var state_machine: RewindableStateMachine
@export var camera: Camera2D
@export var player_id := 1:
	set(id):
		player_id = id

func _enter_tree() -> void:
	player_input.set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	set_physics_process(false)
	if multiplayer.get_unique_id() == player_id:
		camera.make_current()
	else:
		camera.enabled = false

	state_machine.state = &"Idle"
	rollback_synchronizer.process_settings()


func execute_physics() -> void:
	if not multiplayer.has_multiplayer_peer():
		return
	
	_force_update_is_on_floor()
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor
	

func _force_update_is_on_floor():
	var old_velocity = velocity
	velocity = Vector2.ZERO
	move_and_slide()
	velocity = old_velocity
