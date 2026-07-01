extends Node

const SERVER_PORT = 3040
var SERVER_IP = "51.38.225.9"

var player = preload("res://scenes/player.tscn")
var _players_spawn_node: Node
var respawn_point = Vector2(-30, 24)

func _ready() -> void:
	if OS.has_feature("debug"):
		SERVER_IP = "127.0.0.1"

func become_host():
	print("Starting host")
	# _players_spawn_node = get_tree().get_current_scene().get_node("Players")
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	multiplayer.multiplayer_peer = server_peer
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)



func join_as_player(ip = SERVER_IP, port = SERVER_PORT):
	print("Joining")
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(ip, port)
	multiplayer.multiplayer_peer = client_peer
	if not multiplayer.server_disconnected.is_connected(_server_disconnected):
		multiplayer.server_disconnected.connect(_server_disconnected)


func _add_player_to_game(id: int):
	print("Player %s joined" %id)
	
	var player_to_add = player.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	_players_spawn_node.add_child(player_to_add, true)

func _del_player(id: int):
	print("Player %s left" %id)
	if not _players_spawn_node.has_node(str(id)):
		return
	_players_spawn_node.get_node(str(id)).queue_free()


func _server_disconnected():
	print("Server disconnected")
