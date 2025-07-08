extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if multiplayer.is_server():
		body.mark_dead()


func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
