@tool
extends PlayerState

func tick(delta: float, tick: int, is_fresh: bool) -> void:
	# Stop Rider from yelling at me
	if Engine.is_editor_hint():
		return
		
	player.air_jumps_left = player.MAX_AIR_JUMPS
	
	if input.jump_held:
		player.velocity.y = player.JUMP_VELOCITY
	player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)

	player.execute_physics()

	if not player.is_on_floor():
		state_machine.transition("Airborne")
	elif input.input_dir != 0:
		state_machine.transition("Run")
