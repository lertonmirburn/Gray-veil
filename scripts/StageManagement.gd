extends Node
class_name Stage_management

@export var player:Player
@export var enemies:Array[Enemy]=[]
@export var current_weather:WEATHER=WEATHER.CLEAR
@export var can_attack:bool
@onready var valid_move:Dictionary={}
var fog_counter=0
enum STATE{
	TURN_PLAYER,TURN_ENEMY,WINNING,GAME_OVER
}
enum WEATHER{
	FOG,CLEAR
}
@export var current_state:STATE=STATE.TURN_PLAYER
func _ready() -> void:
	BusStage.player_died.connect(_on_player_died)
	BusStage.enemy_die.connect(_on_enemy_died)
	init_actor()
	game_start()
	game_loop()
func init_actor():
	if player:
		player.stage_mg=self
	for enemy in enemies:
		if enemy:
			enemy.initialize(self)
func game_start():
	can_attack=false
	current_weather=WEATHER.CLEAR
func game_loop():
	while current_state!=STATE.WINNING and current_state!=STATE.GAME_OVER:
		player.action()
		await player.end_turn
		if current_state==STATE.WINNING or current_state==STATE.GAME_OVER:
			end_battle()
			return
		for enemy in enemies.duplicate():
			if not is_instance_valid(enemy):
				continue
			enemy.action(current_weather,valid_move)
			await enemy.end_turn
		if current_state==STATE.WINNING or current_state==STATE.GAME_OVER:
			end_battle()
			return
		swap_weather()
	pass
func swap_weather():
	if fog_counter>=3:
		current_weather=WEATHER.CLEAR
		can_attack=false
		fog_counter=0
		return
	else:	
		current_weather=WEATHER.FOG
		can_attack=true
		fog_counter+=1
		return
func _on_player_died():
	current_state=STATE.GAME_OVER
	player.set_process_unhandled_input(false)
func _on_enemy_died(enemy_die:Enemy):
	enemies.erase(enemy_die)
	if enemies.is_empty():
		current_state=STATE.WINNING
func end_battle():
	match current_state:
		STATE.WINNING:
			pass
		STATE.GAME_OVER:
			pass
