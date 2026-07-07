class_name SpawnManager
extends Node2D

var player_scene: PackedScene
@onready var players_spawn: Node2D = get_tree().current_scene.get_node("%PlayersSpawn")
var local_character_choice: String = "cshark"

func _ready() -> void:
	if is_multiplayer_authority():
		multiplayer.peer_disconnected.connect(_on_peer_disconnect)
	else:
		if multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
			request_spawn.rpc_id(1, local_character_choice)
		else:
			# Wait for the handshake to finish before sending the RPC!
			multiplayer.connected_to_server.connect(_on_connected_to_server)
			multiplayer.connection_failed.connect(_on_connection_failed)
	

func _on_connected_to_server() -> void:
	print("Handshake complete! Requesting spawn...")
	request_spawn.rpc_id(1, local_character_choice)


func _on_connection_failed() -> void:
	print("Failed to connect to the server.")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_peer_disconnect(network_id: int) -> void:
	print("Disconnected: %s" % network_id)


func _server_spawn_player(network_id: int, character_id: String) -> void:
	var player_to_add: Player = player_scene.instantiate()
	player_to_add.set_multiplayer_authority(1) 
	player_to_add.name = str(network_id)
	player_to_add.player_id = network_id
	
	player_to_add.character_id = character_id
	players_spawn.add_child(player_to_add)
	print("Player %s spawned as %s" % [network_id, character_id])


@rpc("any_peer", "call_remote", "reliable")
func request_spawn(character_id: String) -> void:
	var sender_id: int = multiplayer.get_remote_sender_id()
	
	if not is_multiplayer_authority():
		return
		
	_server_spawn_player(sender_id, character_id)
