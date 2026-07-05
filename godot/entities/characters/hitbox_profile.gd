class_name HitboxProfile
extends Resource

@export_group("Physics Properties")
@export var shape: Shape2D
@export var offset: Vector2 = Vector2.ZERO

@export_group("Combat Properties")
@export var damage: int = 10
@export var base_knockback: float = 200.0
@export var knockback_scaling: float = 1.0
@export var launch_angle_degrees: float = 45.0