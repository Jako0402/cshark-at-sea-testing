extends PlayerState

func tick(delta: float, tick: int, is_fresh: bool) -> void:
	player.velocity.y += player.gravity * delta
	
	if input.input_dir != 0:
		player.velocity.x = input.input_dir * player.SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)

	player.execute_physics()

	if player.is_on_floor():
		if input.input_dir == 0:
			state_machine.transition("Idle")
		else:
			state_machine.transition("Run")
