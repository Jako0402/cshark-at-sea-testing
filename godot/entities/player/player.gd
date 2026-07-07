class_name Player
extends CharacterBody2D

var speed: float
var jump_velocity: float
var gravity: float
var air_jumps_left: int
var state_tick: int = 0
var damage_taken: int = 0

#  1 = Facing Right
# -1 = Facing Left
var facing_dir: int = 1
var character_data: CharacterData

@export var character_id: String = ""
@onready var rollback_synchronizer: RollbackSynchronizer = $RollbackSynchronizer
@onready var pivot: Node = %Pivot
@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D
@export var player_input: PlayerInput
@export var camera: Camera2D
@export var player_id := 1:
	set(id):
		player_id = id

func _enter_tree() -> void:
	player_input.set_multiplayer_authority(str(name).to_int())


func _ready() -> void:
	set_physics_process(false)	
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	
	if character_id == "":
		character_id = "cshark" # Fallback
	character_data = CharacterRegistry.get_character(character_id)
	
	air_jumps_left = character_data.max_air_jumps
	speed = character_data.speed
	jump_velocity = character_data.jump_velocity
	sprite.sprite_frames = character_data.sprite_frames
	
	var signature_attack: RewindableState = character_data.signature_attack.instantiate()
	signature_attack.name = &"SignatureAttack"
	$RewindableStateMachine.add_child(signature_attack)
	signature_attack.owner = $RewindableStateMachine
	
	if multiplayer.get_unique_id() == player_id:
		camera.make_current()
	else:
		camera.enabled = false
	
	$RewindableStateMachine.state = &"Idle"
	rollback_synchronizer.process_settings()


func execute_physics() -> void:
	if not multiplayer.has_multiplayer_peer():
		return
	
	_force_update_is_on_floor()
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor
	

func _force_update_is_on_floor():
	var old_velocity: Vector2 = velocity
	velocity = Vector2.ZERO
	move_and_slide()
	velocity = old_velocity


func _process(_delta: float) -> void:
	pivot.scale.x = facing_dir


func enable_hitbox(profile: HitboxProfile) -> void:
	var hitbox: Area2D = %HitboxLight
	var col_shape: CollisionShape2D = hitbox.get_node("HitboxLightShape")
	
	# hitbox.active_damage = profile.damage
	# hitbox.active_knockback = profile.knockback
	
	col_shape.shape = profile.shape
	col_shape.position = profile.offset
	col_shape.disabled = false

func disable_hitboxes() -> void:
	var col_shape: CollisionShape2D = %HitboxLight.get_node("HitboxLightShape")
	col_shape.disabled = true


func take_hit(damage: int, knockback: Vector2) -> void:
	damage_taken += damage
	velocity = knockback
	$RewindableStateMachine.transition(&"Hitstun")
