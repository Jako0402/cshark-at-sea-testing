extends Control

const REQUEST_MATCHES = "REQUEST_MATCHES"
const JOIN_MATCH = "JOIN_MATCH"
const PLAYER_JOINED = "PLAYER_JOINED"
const MATCH_PLAYERS = "MATCH_PLAYERS"
const PLAYER_DROPPED = "PLAYER_DROPPED"
const CHECK_MATCH_READY = "CHECK_MATCH_READY"
const MATCH_READY = "MATCH_READY"

# textures
var match_button_texture = preload("res://assets/sprites/coin.png")

var websocket_url = "ws://localhost:8000"
var message_to_send = ""

@onready var web_socket_client: WebSocketClient = $WebSocketClient

signal start_client(ip, port)

# TEMP
var mock_id = str(randi() % 1000)
var mock_user = {
	"playerId": mock_id,
	"userName": "User" + mock_id,
}

func _connect_to_matchmaking_server() -> void:
	var error = web_socket_client.connect_to_url(websocket_url)
	if error != OK:
		print("Error connecting to websocket %s" %[websocket_url])


func _ready() -> void:
	print("Attempting to connect to server")
	print(mock_user)
	$LobbyContainer.hide()
	$MatchesContainer/UserInfo/Username.text = "[center]" + mock_user.userName + "[center]"
	_connect_to_matchmaking_server()

func _send_message(message):
	var json_message = JSON.stringify(message)
	web_socket_client.send(json_message)

func _on_websocket_client_connection_close():
	var ws = web_socket_client.get_socket()
	print("Client disconnected with \ncode: %s \nreason: %s:" % [ws.get_close_code(), ws.get_close_reason()])

func _on_websocket_client_connected_to_server():
	print("Client connected")
	$MatchmakingStatus.text = "[center]Looking for matches...[center]"
	
	var request_matches = {
		"op": REQUEST_MATCHES,
		"usernamae": mock_user.userName
	}
	_send_message(request_matches)

func _on_websocket_message_received(message):
	print("Message recived: %s", % message)
	_process_received_message(message)

func _process_received_message(message):
	if typeof(message) == TYPE_STRING:
		var response_msg = str_to_var(message)
		
		if response_msg.op:
			print("Processing op: %s" % response_msg.op)
			
			if response_msg.op == REQUEST_MATCHES:
				print("REQUEST_MATCHES")
				var matches = response_msg.response
				if matches && matches.size() > 0:
					_add_matches_to_ui(matches)
					$MatchmakingStatus.text = "[center]Choose a match to join[center]"
			
			elif response_msg.op == MATCH_PLAYERS:
				print("MATCH_PLAYERS")
				_enter_match_lobby(response_msg.response)
			
			elif response_msg.op == MATCH_READY:
				print("MATCH_READY")
				print("Connection info: %s, %s" % [response_msg.response.io, response_msg.response.port])
				$MatchmakingStatus.text = "[center]Match ready. Staring game[center]"
				start_client.emit(response_msg.response.io, response_msg.response.port)
				web_socket_client.close(1000, "Game started, lobby ended normally.")
			
			elif response_msg.op == PLAYER_JOINED || response_msg.op == PLAYER_DROPPED:
				print(response_msg.op)
				var match_with_players = response_msg.response
				_build_player_lobby_lists(match_with_players)

func _add_matches_to_ui(matches):
	for match_index in range(matches.size()):
		print(matches[match_index])
		
		var button_text = "# %s | %s | %s" % [str(match_index), matches[match_index].team_makeup, matches[match_index].map]
		var button_label := RichTextLabel.new()
		button_label.set_text(button_text)
		button_label.set_size(Vector2(800, 100))
		button_label.set_position(Vector2(45, 30))
		button_label.add_theme_font_size_override("normal_font_size", 50)
		button_label.fit_content = true
		button_label.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		
		var button := Button.new()
		button.add_child(button_label)
		button.pressed.connect(self._join_match.bind(matches[match_index]))
		button.custom_minimum_size = Vector2(800, 100)
		$MatchesContainer/AvailableMatches.add_child(button)
	
func _join_match(match_to_join: Dictionary):
	$MatchesContainer/AvailableMatches.hide()
	$MatchesContainer/MatchStatus.text = "Entering match lobby"
	
	var join_match_message = {
		"op": JOIN_MATCH,
		"matchId": match_to_join.id,
		"playerId": mock_user.playerId,
		"username": mock_user.userName
	}
	_send_message(join_match_message)
	
func _enter_match_lobby(match_to_enter):
	print("Enter match lobby")
	print(match_to_enter)
	
	$MatchesContainer.hide()
	$LobbyContainer.show()
	$MatchmakingStatus.text = "[center]Waiting for players[center]"
	$LobbyContainer/MapInfo.text = "[center]" + match_to_enter.matchInfo.map + " | " + match_to_enter.matchInfo.team_makeup + "[center]"
	_build_player_lobby_lists(match_to_enter.users)
	
	# TODO: FIX TO SERVERSIDE
	var match_id = match_to_enter.matchInfo.id
	var check_match_ready = {
		"op": CHECK_MATCH_READY,
		"matchId": match_id
	}
	_send_message(check_match_ready)

func _build_player_lobby_lists(match_players):
	for team_child in $LobbyContainer/Teams/Team1.get_children():
		team_child.queue_free()
	for team_child in $LobbyContainer/Teams/Team2.get_children():
		team_child.queue_free()
	
	for player in match_players:
		print("match_players")
		print(player)
		var button_text = "%s" % [player.player_id]
		
		var button_label := RichTextLabel.new()
		button_label.set_text(button_text)
		button_label.set_size(Vector2(800, 100))
		button_label.set_position(Vector2(45, 30))
		button_label.add_theme_font_size_override("normal_font_size", 50)
		button_label.fit_content = true
		button_label.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		
		var button := Button.new()
		button.add_child(button_label)
		button.custom_minimum_size = Vector2(800, 100)
		
		if player.team == "1":
			$LobbyContainer/Teams/Team1.add_child(button)
		elif player.team == "2":
			$LobbyContainer/Teams/Team2.add_child(button)
		else:
			print("Error: Player not assigned team")
