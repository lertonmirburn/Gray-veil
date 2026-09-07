extends CharacterBody2D
class_name Player
signal end_turn


const tile_size: Vector2 = Vector2(16,16)
#var sprite_node_pos_tween: Tween

@export var stats: EntityStats
var current_ap: int = 0
var is_my_turn: bool = false
var movement_buff: int = 0

func _ready() -> void:
	current_ap = stats.ap
	movement_buff = stats.movement_speed


func action() -> void:
	if stats:
		current_ap=stats.ap
	is_my_turn=true

func _unhandled_input(event: InputEvent) -> void:
	#if not is_my_turn or current_ap <= 0 :
		#return
	if event.is_action_pressed("ui_accept"):
		current_ap = stats.ap
		print("Turn Ended. AP Refreshed!")
		return
	if current_ap <= 0 :
		return
	var dir = Vector2.ZERO
	#if Input.is_action_just_pressed("ui_up") and !$up.is_colliding():
	if Input.is_action_just_pressed("ui_up"):
		dir = Vector2(0,-1)
	#elif Input.is_action_just_pressed("ui_down") and !$down.is_colliding():
	if Input.is_action_just_pressed("ui_down"):	
		dir = Vector2(0,1)
	#elif Input.is_action_just_pressed("ui_left") and !$left.is_colliding():
	elif Input.is_action_just_pressed("ui_left"):
		dir = Vector2(-1,0)
	#elif Input.is_action_just_pressed("ui_right") and !$right.is_colliding():
	elif Input.is_action_just_pressed("ui_right"):	
		dir = Vector2(1,0)
	if dir != Vector2.ZERO:
		get_viewport().set_input_as_handled() 
		_try_move(dir)
		
		
func _try_move(dir: Vector2) -> void:
	if test_move(global_transform, dir * tile_size):
		print("Bonk! Wall detected.")
		return
	else:
		print("Can move")
	_execute_move(dir)
	

func _execute_move(dir:Vector2):
	if movement_buff>1: 
		global_position += dir * tile_size
		movement_buff-=1
	else:
		current_ap-=1
		print("Moved. AP left: ", current_ap, " | Noise generated: ", stats.noise)
		global_position += dir * tile_size
		movement_buff = stats.movement_speed
	#$Sprite2D.global_position -= dir * tile_size
	
	#if sprite_node_pos_tween:
		#sprite_node_pos_tween.kill()
	#sprite_node_pos_tween = create_tween()
	#sprite_node_pos_tween = create_tween()
	#sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	#sprite_node_pos_tween.tween_property($Sprite2D,"global_position",global_position,0.185).set_trans(Tween.TRANS_SINE)
	#await  sprite_node_pos_tween.finished
	
	if current_ap <=0:
		is_my_turn=false
		end_turn.emit()
		
func die() -> void:
	#BusStage.player_died.emit()
	queue_free()
