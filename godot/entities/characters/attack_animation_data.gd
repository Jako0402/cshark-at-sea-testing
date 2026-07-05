class_name AttackAnimationData
extends Resource

@export_group("Phase Durations (in Ticks)")
@export var startup_ticks: int = 10
@export var active_ticks: int = 5
@export var recovery_ticks: int = 15

@export_group("Hitboxes")
@export var active_hitbox_frames: Array[HitboxProfile] = []