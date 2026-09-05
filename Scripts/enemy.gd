extends CharacterBody2D
class_name Enemy
@export var stats:EntityStats
var player:Player
var pos_save:Vector2i
var actor:Node
var value_noise:int
var has_target:bool=false
func on_hear_noise(source:Node,sound_pos:Vector2i,noise:int):
	actor=source
	pos_save=sound_pos
	value_noise=noise
	has_target=true
func action(current_weather:Stage_Management.WEATHER):
	if has_target==false:
		random_move()
	#match current_weather:
		#Stage_Management.WEATHER.FOG:
			#behavior_foggy()
			#return
		#Stage_Management.WEATHER.CLEAR:
			#behavier_clear()
	else:
		

	
	
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
	
	pass
