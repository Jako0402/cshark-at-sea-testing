@tool
extends PlayerState

const SHORT_HOP_GRAVITY_MULT: float = 2.5

func tick(delta: float, tick: int, is_fresh: bool) -> void:
	# Stop Rider from yelling at me
	if Engine.is_editor_hint():
		return
		
	if input.input_dir != 0:
		player.facing_dir = sign(input.input_dir)

	if input.jump_just_pressed and player.air_jumps_left > 0:
		player.velocity.y = player.jump_velocity
		player.air_jumps_left -= 1
		
	var current_gravity: float = player.gravity
	if player.velocity.y < 0 and not input.jump_held:
		current_gravity *= SHORT_HOP_GRAVITY_MULT
		
	player.velocity.y += current_gravity * delta
	
	if input.input_dir != 0:
		player.velocity.x = input.input_dir * player.speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.speed)

	player.execute_physics()

	if input.attack_just_pressed:
		state_machine.transition(&"SignatureAttack")
	elif player.is_on_floor():
		if input.input_dir == 0:
			state_machine.transition(&"Idle")
		else:
			state_machine.transition(&"Run")
