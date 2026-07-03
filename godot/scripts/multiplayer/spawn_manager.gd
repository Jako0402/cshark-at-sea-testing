class_name SpawnManager
extends Node2D

var player_scene: PackedScene
@onready var players_spawn: Node2D = get_tree().current_scene.get_node("%PlayersSpawn")


func _ready() -> void:
	if is_multiplayer_authority():
		multiplayer.peer_connected.connect(_on_peer_connect)
		multiplayer.peer_disconnected.connect(_on_peer_disconnect)
	

func _process(delta: float) -> void:
	pass


func _on_peer_connect(network_id: int) -> void:
	print("Connected: %s" % network_id)
	_add_player_to_game(network_id)


func _on_peer_disconnect(network_id: int) -> void:
	print("Disconnected: %s" % network_id)


func _add_player_to_game(network_id: int) -> void:
	var player_to_add: Player = player_scene.instantiate()
	player_to_add.set_multiplayer_authority(1)
	player_to_add.name = str(network_id)
	player_to_add.player_id = network_id
	print("network_id: %s and pid: %s" % [network_id, player_to_add.player_id])
	players_spawn.add_child(player_to_add)
	print("Player added to game")
