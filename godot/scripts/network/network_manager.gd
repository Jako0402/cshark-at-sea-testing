extends Node

const SERVER_PORT: int = 3040
var SERVER_IP: String = "51.38.225.9"

const GAME_SCENE: String = "res://scenes/levels/game.tscn"
var is_server: bool = false

func _ready() -> void:
	if OS.has_feature("debug"):
		SERVER_IP = "127.0.0.1"


func _process(delta: float) -> void:
	pass


func load_game_scene() -> void: 
	get_tree().call_deferred(&"change_scene_to_packed", preload(GAME_SCENE))

	
func create_client(host_ip: String = SERVER_IP, host_port: int = SERVER_PORT) -> void: 
	is_server = false
	var enet_network_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	enet_network_peer.create_client(host_ip, host_port)
	multiplayer.multiplayer_peer = enet_network_peer
	print("Client peer created!")
	

func create_server() -> void: 
	is_server = true
	var enet_network_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	enet_network_peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = enet_network_peer
	print("Server created!")
