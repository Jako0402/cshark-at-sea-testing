class_name PlayerState
extends RewindableState

var player: Player
var input: PlayerInput
var player_state_machine: RewindableStateMachine

func _ready() -> void:
	# Grab references once so all child states have them
	player = owner as Player
	input = player.player_input
	player_state_machine = get_parent() as RewindableStateMachine
