extends Node


func become_host():
	print("Become host pressed")
	%MultiplayerHUD.hide()
	MultiplayerManager.become_host()

func join_as_player_2():
	print("Join as player pressed")
	%MultiplayerHUD.hide()
	MultiplayerManager.join_as_player_2()
