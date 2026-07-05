@tool
class_name PlayerState
extends RewindableState

var player: Player
var input: PlayerInput
var player_state_machine: RewindableStateMachine

func _ready() -> void:
	# Stop Rider from yelling at me
	if Engine.is_editor_hint():
		return
	# Grab references once so all child states have them
	player_state_machine = get_parent() as RewindableStateMachine
	player = player_state_machine.get_parent() as Player
	input = player.player_input

func enter(previous_state: RewindableState, tick: int) -> void:
	player.state_tick = 0
