extends CanvasLayer

@onready var continue_button: Button = $PanelContainer/MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Continue


func _ready() -> void:
	if BusStage.current_stage==2:
		continue_button.visible = false

func _on_continue_pressed() -> void:
	get_tree().create_timer(0.2).timeout
	BusStage.current_stage+=1
	get_tree().change_scene_to_file("res://scenes/Game_management.tscn")
	pass


func _on_return_menu_pressed() -> void:
	if BusStage.current_stage==2:
		BusStage.current_stage+=1
	get_tree().change_scene_to_file("res://scenes/MainmenuScreen.tscn")
	pass # Replace with function body.
