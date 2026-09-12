extends CharacterBody2D
class_name Player
signal end_turn


const tile_size: Vector2 = Vector2(16,16)
#var sprite_node_pos_tween: Tween
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Area2D
@onready var item_message: Label = $Label

@export var stats: EntityStats
var current_ap: int = 0
var is_my_turn: bool = false
var movement_buff: int = 0
var stage_mg:Stage_management
var grid_pos: Vector2i
var last_direction: Vector2 = Vector2.RIGHT
var is_attacking: bool = false
var hitbox_offset: Vector2
var mouse_pos = get_global_mouse_position()
var collection: Array[String] = []

func _ready() -> void:
	current_ap = stats.ap
	movement_buff = 0
	var tile_coord = (global_position / tile_size).floor()
	global_position = (tile_coord * tile_size) + (tile_size / 2.0)
	grid_pos = Vector2i(tile_coord)
	
	hitbox_offset = hitbox.position
	hitbox.monitoring = false
	update_hitbox_offset()
	


func action() -> void:
	if stats:
		current_ap=stats.ap
	is_my_turn=true
#-------------------------------------------------------------------------------
# ANIMATION SYSTEM
#-------------------------------------------------------------------------------
func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play(prefix + "_right")
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_back")
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_front")

func process_animation(direction: Vector2) -> void:
	if is_attacking:
		return
	if direction != Vector2.ZERO:
		play_animation("idle",direction)
		
#-------------------------------------------------------------------------------
# MOVEMENT
#-------------------------------------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if not is_my_turn or current_ap <= 0 :
		BusStage.player_end_turn.emit()
		return
	if event.is_action_pressed("ui_accept"):
		current_ap = stats.ap
		is_my_turn=false
		print("Turn Ended. AP Refreshed!")
		BusStage.player_end_turn.emit()
		return
	#if current_ap <= 0 :
		#return
	var dir = Vector2.ZERO
		
	#if Input.is_action_just_pressed("ui_up") and !$up.is_colliding():
	if Input.is_action_just_pressed("up"):
		dir = Vector2(0,-1)
		process_animation(dir)
	#elif Input.is_action_just_pressed("ui_down") and !$down.is_colliding():
	elif Input.is_action_just_pressed("down"):	
		dir = Vector2(0,1)
		process_animation(dir)
	#elif Input.is_action_just_pressed("ui_left") and !$left.is_colliding():
	elif Input.is_action_just_pressed("left"):
		dir = Vector2(-1,0)
		process_animation(dir)
	#elif Input.is_action_just_pressed("ui_right") and !$right.is_colliding():
	elif Input.is_action_just_pressed("right"):	
		dir = Vector2(1,0)
		process_animation(dir)
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()
	if event.is_action_pressed("interact"):
		interact()
	# Skip any movement if is_attacking
	if is_attacking:
		dir = Vector2.ZERO
		return
		
	if dir != Vector2.ZERO:
		get_viewport().set_input_as_handled() 
		_try_move(dir)
		
		last_direction = dir
		update_hitbox_offset()
		
func _process(delta: float) -> void:
	if not is_my_turn or is_attacking:
		return
	
	if Input.is_action_pressed("aim"):
		aim()
		update_hitbox_offset()
	if Input.is_action_just_released("aim"):
		play_animation("idle", last_direction)

#-------------------------------------------------------------------------------
# COLLISION DETECTION
#-------------------------------------------------------------------------------
func _try_move(dir: Vector2) -> void:
	#if test_move(global_transform, dir * tile_size):
		#print("Bonk! Wall detected.")
		#return
	#else:
		#print("Can move")
	var target_grid_pos = grid_pos + Vector2i(dir)
	if stage_mg and stage_mg.astar:
		if not stage_mg.astar.is_in_boundsv(target_grid_pos):
			print("Bonk! Reached the edge of the map.")
			return
			
		if stage_mg.astar.is_point_solid(target_grid_pos):
			print("Bonk! Entity or wall detected by StageManager.")
			return
		
	_execute_move(dir)
	
#-------------------------------------------------------------------------------
# ACTION POINT SYSTEM
#-------------------------------------------------------------------------------
func _execute_move(dir:Vector2):
	var old_grid_pos = grid_pos
	grid_pos += Vector2i(dir)
	global_position += dir * tile_size
	if stage_mg:
		stage_mg.mark_entity_moved(self, old_grid_pos, grid_pos)
	current_ap-=1
	print("Moved. AP left: ", current_ap, " | Now at : ", grid_pos)
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
		BusStage.player_end_turn.emit()
		
#-------------------------------------------------------------------------------
# ATTACK
#-------------------------------------------------------------------------------
func aim() -> void:
	var direction := global_position.direction_to(get_global_mouse_position())
	if abs(direction.x) > abs(direction.y):
		last_direction = Vector2.RIGHT if direction.x > 0 else Vector2.LEFT
	else:
		last_direction = Vector2.DOWN if direction.y > 0 else Vector2.UP
	play_animation("aim", last_direction)

func attack() -> void:
	is_attacking = true
	hitbox.monitoring = true
	play_animation("attack",last_direction)
	await animated_sprite_2d.animation_finished
	current_ap-=1
	print("Attacked ! AP left :", current_ap)
	hitbox.monitoring = false
	is_attacking = false
	play_animation("idle", last_direction)


func _on_animated_sprite_2d_animation_finished() -> void:
	pass

func update_hitbox_offset() -> void:
	var x := hitbox_offset.x
	var y := hitbox_offset.y
	match last_direction:
		Vector2.LEFT:
			hitbox.position = Vector2(-x,y)
		Vector2.RIGHT:
			hitbox.position = Vector2(x,y)
		Vector2.UP:
			hitbox.position = Vector2(y,-x)
		Vector2.DOWN:
			hitbox.position = Vector2(-y,x)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_attacking and body.name.begins_with("Enemy"):
		print("Player hit the enemy")
		print(body)
		BusStage.enemy_die.emit(body)
		
#-------------------------------------------------------------------------------
# INTERACT
#-------------------------------------------------------------------------------
func interact() -> void:
	var areas: Array[Area2D] = $InteractableArea.get_overlapping_areas()
	
	for area in areas:
		print("AREA: ", area.name)
		if area is Interactable:
			area.interact()
			return
			
func add_item(item: String) -> void:
	collection.append(item)
	
	item_message.text = "License plate added: " + item
	item_message.show()
	await get_tree().create_timer(2.0).timeout
	item_message.hide()
	print("Collected: ", item)
	
func has_item(item_name: String) -> bool:
	for item in collection:
		if item == item_name:
			return true

	return false
#-------------------------------------------------------------------------------
# DEATH
#-------------------------------------------------------------------------------
func die() -> void:
	BusStage.player_died.emit()
	queue_free()
