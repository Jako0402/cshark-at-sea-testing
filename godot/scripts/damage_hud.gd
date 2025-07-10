extends Control


@export var players: Node2D
@export var custom_font: Font
@export var font_size: int = 16
@onready var damage_list: VBoxContainer = $HUD/DamageList  # The UI container for displaying the damage

# Method to update the UI
func update_ui():
	for child in damage_list.get_children():
		child.queue_free()
	for player in players.get_children():
		var label: Label = Label.new()
		
		label.add_theme_font_override("font", custom_font)
		label.add_theme_font_size_override("font", font_size)
		label.text = "Player " + str(player.player_id) + ": " + str(player.damage)
		
		damage_list.add_child(label)

# Listen for damage changes (this happens automatically because of @sync)
func _process(delta):
	if not OS.has_feature("dedicated_server"):
		update_ui()
