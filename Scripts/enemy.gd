extends CharacterBody2D
class_name Enemy
@export var stats:EntityStats
@export var patrol_point:Array=[]
var current_patrol_index:int =0
var player:Player
var pos_save:Vector2i
var actor:Node
var value_noise:int
var has_target:bool=false
@export var stage_mg:Stage_management
func initialize(stage_management:Stage_management):
	stage_mg=stage_management
	BusStage.enemy_die.connect(is_alive)
	
func on_hear_noise(source:Node,sound_pos:Vector2i,noise:int):
	actor=source
	pos_save=sound_pos
	value_noise=noise
	has_target=true
func action(current_weather:Stage_management.WEATHER):
	match current_weather:
		Stage_management.WEATHER.FOG:
			behavior_foggy()
		Stage_management.WEATHER.CLEAR:
			behavier_clear_sky()
	end_turn()

	
	
func have_target(source:Node,sound_pos:Vector2i,noise:int):
	if source==self:
		return
	elif source is Player:
		if abs(sound_pos.x-self.global_position.x)+abs(sound_pos.y-self.global_position.y)<=noise:
			move(sound_pos)
			return
	random_move()
func move(pos:Vector2i):
	
	pass
func random_move():
	
	pass
func attack():
	
	pass
func behavior_foggy():
	pass
	
func behavier_clear_sky():
	if 
	pass
func on_die():
	self.free()
	end_turn()
	pass
func is_alive(node:Node):
	if node == self:
		on_die()
	pass
func end_turn():
	
	pass
