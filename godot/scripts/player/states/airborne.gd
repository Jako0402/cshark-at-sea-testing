@tool
extends PlayerState

const SHORT_HOP_GRAVITY_MULT: float = 2.5

func tick(delta: float, tick: int, is_fresh: bool) -> void:
	# Stop Rider from yelling at me
	if Engine.is_editor_hint():
		return
		
	if input.jump_just_pressed and player.air_jumps_left > 0:
		player.velocity.y = player.JUMP_VELOCITY
		player.air_jumps_left -= 1
		
	var current_gravity = player.gravity
	if player.velocity.y < 0 and not input.jump_held:
		current_gravity *= SHORT_HOP_GRAVITY_MULT
		
	player.velocity.y += current_gravity * delta
	
	if input.input_dir != 0:
		player.velocity.x = input.input_dir * player.SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)

	player.execute_physics()

	if player.is_on_floor():
		if input.input_dir == 0:
			state_machine.transition(&"Idle")
		else:
			state_machine.transition(&"Run")
