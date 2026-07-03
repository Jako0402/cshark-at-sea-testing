extends Node2D

@export var player_scene: PackedScene

func _ready() -> void:
	if NetworkManager.is_server: 
		var spawn_manager_scene = load("res://scenes/multiplayer/spawn_manager.tscn")
		var spawn_manager = spawn_manager_scene.instantiate()
		spawn_manager.player_scene = player_scene
		add_child(spawn_manager)


func _process(delta: float) -> void:
	pass
