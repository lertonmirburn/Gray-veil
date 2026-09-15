extends CanvasLayer
class_name main_menu_screen



func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Game_management.tscn")
	
	pass # Replace with function body.


func _on_credit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Credit.tscn")
	
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit(0)
