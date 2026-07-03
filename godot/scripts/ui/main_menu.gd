extends Control


func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server")
		_create_server()


func _on_find_match_pressed() -> void:
	print("FindMatch button pressed")
	NetworkManager.create_client()
	NetworkManager.load_game_scene()
	

func _create_server() -> void:
	NetworkManager.create_server()
	NetworkManager.load_game_scene()
