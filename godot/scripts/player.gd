extends CharacterBody2D

const SPEED = 140.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_hitbox: CollisionShape2D = $AttackHitbox/CollisionHitbox

@export var player_id := 1:
	set(id):
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id)

var direction = 1
var do_jump = false
var attack = false
var damage = 0

var _is_on_floor = true
var _is_attacking = false

func _ready() -> void:
	if multiplayer.get_unique_id() == player_id:
		%Camera2D.make_current()
	else:
		%Camera2D.enabled = false

func _apply_animations(delta):
	# Flip sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	# Animation
	if _is_attacking:
		animated_sprite.play("attack")	
	elif _is_on_floor:
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")


func _apply_movement_from_input(delta):
	# Add the gravity.
	if not _is_on_floor:
		velocity += get_gravity() * delta

	# Handle jump.
	if do_jump and _is_on_floor:
		velocity.y = JUMP_VELOCITY
		do_jump = false
	else:
		do_jump = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = %InputSynchronizer.input_direction
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _attack_from_input(delta):
	if attack and not _is_attacking:
		_is_attacking = true
		attack = false
		
		collision_hitbox.disabled = false
		
		$AttackDurationTimer.start()
		

func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		_is_on_floor = is_on_floor()
		_apply_movement_from_input(delta)
		_attack_from_input(delta)

	if not multiplayer.is_server() || MultiplayerManager.host_mode:
		_apply_animations(delta)

func mark_dead():
	print("A player died")
	$RespawnTimer.start()

func _respawn():
	position = MultiplayerManager.respawn_point
	print("A player respawned")

func finish_attack():
	collision_hitbox.disabled = true
	_is_attacking = false

func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name != str(player_id):
		body.damage = body.damage + 10
		body.velocity.y = -body.damage * 10
		
