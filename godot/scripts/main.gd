extends Node

const LEVEL = preload("res://scenes/game.tscn")

func _ready() -> void:
	$UI/UsernameInput.text = str(randi() % 1000)
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server")
		become_host()


func _on_find_match_pressed() -> void:
	print("Find match pressed")
	$UI.hide()
	
	var lobby = preload("res://scenes/lobby.tscn").instantiate()
	lobby.start_client.connect(join_as_player)
	$LobbyPlaceholder.add_child(lobby)
	

func become_host():
	print("Become host pressed")
	_change_level(LEVEL)
	MultiplayerManager.become_host()
	
	

func join_as_player(ip, port):
	print("Join as player pressed")
	$LobbyPlaceholder.get_child(0).queue_free()
	MultiplayerManager.join_as_player(ip, port)


func _change_level(scene: PackedScene) -> void:
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	level.add_child(scene.instantiate())
