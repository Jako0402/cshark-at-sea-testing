extends PlayerState

func tick(delta: float, tick: int, is_fresh: bool) -> void:
	if input.input_jump > 0:
		player.velocity.y = player.JUMP_VELOCITY * input.input_jump	
	player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)

	player.execute_physics()

	if not player.is_on_floor():
		state_machine.transition("Airborne")
	elif input.input_dir != 0:
		state_machine.transition("Run")
