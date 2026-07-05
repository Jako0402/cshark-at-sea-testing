@tool
extends PlayerState

enum Phase { STARTUP, ACTIVE, RECOVERY, DONE }

var current_phase: Phase
var phase_tick: int
var already_hit: Array[Node2D] = []

@export var attack_data: AttackAnimationData

func enter(previous_state: RewindableState, tick: int) -> void:
	current_phase = Phase.STARTUP
	phase_tick = 0
	already_hit.clear()


func tick(delta: float, tick: int, is_fresh: bool) -> void:
	# Stop Rider from yelling at me
	if Engine.is_editor_hint():
		return
	player.state_tick += 1
	phase_tick += 1		
	
	# Normal movement (copy from airborne)
	if input.input_dir != 0:
			player.facing_dir = sign(input.input_dir)
	if input.jump_just_pressed and player.air_jumps_left > 0:
		player.velocity.y = player.jump_velocity
		player.air_jumps_left -= 1
	var current_gravity: float = player.gravity
	if player.velocity.y < 0 and not input.jump_held:
		current_gravity *= 2.5
	player.velocity.y += current_gravity * delta
	if input.input_dir != 0:
		player.velocity.x = input.input_dir * player.speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.speed)
	player.execute_physics()
	
	match current_phase:
		Phase.STARTUP:
			if phase_tick >= attack_data.startup_ticks:
				current_phase = Phase.ACTIVE
				phase_tick = 0
				_process_active_frames() 
				
		Phase.ACTIVE:
			if phase_tick >= attack_data.active_ticks:
				current_phase = Phase.RECOVERY
				phase_tick = 0 
			else:
				_process_active_frames()
				
		Phase.RECOVERY:
			if phase_tick >= attack_data.recovery_ticks:
				current_phase = Phase.DONE
		
		Phase.DONE:
			if player.is_on_floor():
				state_machine.transition("Idle")
			else:
				state_machine.transition("Airborne")
				
	player.execute_physics()


func _process_active_frames() -> void:
	var frame_index: int = phase_tick - 1 
	
	if frame_index < attack_data.active_hitbox_frames.size():
		var current_profile: HitboxProfile = attack_data.active_hitbox_frames[frame_index]
		player.enable_hitbox(current_profile)
		
		# 1. Grab the Hitbox Area2D
		var hitbox_area: Area2D = player.get_node("%HitboxLight")
		
		# 2. Poll for overlapping AREAS (Hurtboxes), not BODIES (Physics)
		var overlapping_areas = hitbox_area.get_overlapping_areas()
		
		for area in overlapping_areas:
			# 3. Ensure we are only interacting with Hurtboxes
			if area.name == "Hurtbox":
				
				# 4. Navigate up the tree to find the Player node.
				# In image_611345.png, the structure is Player -> Pivot -> Hurtbox.
				# 'owner' safely grabs the root of the instantiated Player scene.
				var enemy = area.owner as Player
				
				# Fallback if 'owner' isn't set (e.g., built entirely in code):
				if enemy == null:
					enemy = area.get_parent().get_parent() as Player
				
				# 5. Check if valid, not ourselves, and not already hit this attack
				if enemy != null and enemy != player and not enemy in already_hit:
					_apply_hit(enemy, current_profile)
					already_hit.append(enemy)

func _apply_hit(enemy: Player, profile: HitboxProfile) -> void:
	var k_base: float = profile.base_knockback
	var k_scale: float = profile.knockback_scaling
	var target_damage: int = enemy.damage_taken
	var target_weight: float = enemy.character_data.weight_multiplier
	
	# 1. The Knockback Formula
	var force: float = k_base + ((target_damage * k_scale * 10.0) / target_weight)
	
	# 2. Apply the Angle
	var angle_rads: float = deg_to_rad(profile.launch_angle_degrees)
	
	# Flip angle if the attacker is facing left
	if player.facing_dir < 0:
		angle_rads = PI - angle_rads
	
	# Godot's Vector2.from_angle(0) points RIGHT. Y is down, so we subtract Y to launch UP.
	var knockback_vector: Vector2 = Vector2.from_angle(angle_rads)
	knockback_vector.y = -abs(knockback_vector.y) 
	knockback_vector *= force
	
	# Send the hit to the enemy
	enemy.take_hit(profile.damage, knockback_vector)
