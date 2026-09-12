extends Node2D
class_name GameManager


@export var stages: Array[PackedScene]=[]
@onready var stage_holder: Node2D = $Current_stage_holder


var current_stage_node: Node = null

func _ready() -> void:
	BusStage.battle_won.connect(_on_battle_won)
	BusStage.battle_lost.connect(_on_battle_lost)
	if BusStage.current_stage==3:
		BusStage.current_stage=0
		current_stage_node=null	
	if BusStage.current_stage<=2:
		load_stage(stages[BusStage.current_stage])
func load_stage(stage_to_load: PackedScene) -> void:
	if is_instance_valid(current_stage_node):
		current_stage_node.queue_free()
		await get_tree().process_frame

	current_stage_node = stage_to_load.instantiate()
	stage_holder.add_child(current_stage_node)

func _on_battle_won() -> void:
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/WinScreen.tscn")

func _on_battle_lost() -> void:
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/GameOverScreen.tscn")
