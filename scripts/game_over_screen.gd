extends CanvasLayer
class_name game_over_screen



func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainmenuScreen.tscn")
	pass # Replace with function body.


func _on_return_button_pressed() -> void:
	get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/MainmenuScreen.tscn")
	pass # Replace with function body.
