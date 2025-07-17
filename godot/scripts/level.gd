extends Node2D

func _ready() -> void:
	MultiplayerManager._players_spawn_node = $Players
	print("Updaating spawn node: %s" % $Players)
