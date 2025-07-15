extends Control

var websocket_url = "ws://localhost:8000"
var message_to_send = ""

@onready var web_socket_client: WebSocketClient = $WebSocketClient

func _connect_to_matchmaking_server() -> void:
	var error = web_socket_client.connect_to_url(websocket_url)
	if error != OK:
		print("Error connecting to websocket %s" %[websocket_url])


func _ready() -> void:
	print("Attempting to connect to server")
	_connect_to_matchmaking_server()

func _on_websocket_client_connection_close():
	var ws = web_socket_client.get_socket()
	print("Client disconnected with \ncode: %s \nreason: %s:" % [ws.get_close_code(), ws.get_close_reason()])

func _on_websocket_client_connected_to_server():
	print("Client connected")

func _on_websocket_message_received(message):
	print("Message recived: %s", % message)
