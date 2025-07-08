extends Control

signal host_game_pressed
signal join_game_pressed

func _on_host_game_pressed() -> void:
	host_game_pressed.emit()


func _on_join_as_player_2_pressed() -> void:
	join_game_pressed.emit()
