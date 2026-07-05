@tool
extends PlayerState

func tick(delta: float, tick: int, is_fresh: bool) -> void:
	# Stop Rider from yelling at me
	if Engine.is_editor_hint():
		return
		
	if input.input_dir != 0:
		player.facing_dir = sign(input.input_dir)

	player.air_jumps_left = player.character_data.max_air_jumps
	
	if input.jump_held:
		player.velocity.y = player.jump_velocity
		
	player.velocity.x = input.input_dir * player.speed

	player.execute_physics()

	if not player.is_on_floor():
		state_machine.transition(&"Airborne")
	elif input.attack_just_pressed:
		state_machine.transition(&"SignatureAttack")
	elif input.input_dir == 0:
		state_machine.transition(&"Idle")
