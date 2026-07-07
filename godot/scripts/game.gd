extends Node2D

@export var player_scene: PackedScene

const SPAWN_MANAGER_SCENE: PackedScene = preload("res://scenes/multiplayer/spawn_manager.tscn")

func _ready() -> void:
	var spawn_manager: Node = SPAWN_MANAGER_SCENE.instantiate()
	spawn_manager.player_scene = player_scene
	spawn_manager.local_character_choice = NetworkManager.local_character
	add_child(spawn_manager)


func _process(delta: float) -> void:
	pass
