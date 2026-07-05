class_name CharacterData
extends Resource

@export var character_name: String = "Character name"
@export_group("Movement")
@export var speed: float = 140.0
@export var jump_velocity: float = -400.0
@export var weight_multiplier: float = 1.0 
@export var max_air_jumps: int = 1

@export_group("Visuals")
@export var sprite_frames: SpriteFrames 

@export_group("Signature Attacks")
@export var signature_attack: PackedScene