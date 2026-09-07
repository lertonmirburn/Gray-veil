extends Node
class_name Stage_management

const TILE_SIZE: float = 16.0
#1
@export var player: Player
@export var enemies: Array[Enemy] = []
@export var current_weather: WEATHER = WEATHER.CLEAR
@export var can_attack: bool = false
@onready var valid_move: Dictionary = {}

@export var map_width: int = 20
@export var map_height: int = 20
@export var tile_floor: TileMapLayer
@export var tile_wall: TileMapLayer

var astar: AStarGrid2D = AStarGrid2D.new()
var fog_counter: int = 0

enum STATE {
	TURN_PLAYER,
	TURN_ENEMY,
	WINNING,
	GAME_OVER
}

enum WEATHER {
	FOG,
	CLEAR
}

@export var current_state: STATE = STATE.TURN_PLAYER

func _ready() -> void:
	#2
	BusStage.player_died.connect(_on_player_died)
	BusStage.enemy_die.connect(_on_enemy_died)
	init_grid(map_width, map_height)
	init_actor()
	game_start()
	game_loop()

func init_grid(_w: int = 0, _h: int = 0) -> void:
	if not tile_floor:
		return


	var rect: Rect2i = tile_floor.get_used_rect()
	
	astar.region = rect
	astar.cell_size = Vector2(TILE_SIZE, TILE_SIZE)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()


	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			astar.set_point_solid(Vector2i(x, y), true)


	for cell in tile_floor.get_used_cells():
		var is_wall: bool = false
		if tile_wall:
			is_wall = (tile_wall.get_cell_source_id(cell) != -1)
			
		if not is_wall:
			valid_move[cell] = null
			astar.set_point_solid(cell, false)

func init_actor() -> void:
	#3
	if player:
			player.stage_mg = self
			print(player.grid_pos)
			mark_entity(player,player.grid_pos)
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.initialize(self)
			
			mark_entity(enemy, enemy.grid_pos)

func game_start() -> void:
	can_attack = false
	current_weather = WEATHER.CLEAR

func game_loop() -> void:
	while current_state != STATE.WINNING and current_state != STATE.GAME_OVER:
		current_state = STATE.TURN_PLAYER
		#4
		player.action()
		await player.end_turn
		if current_state == STATE.WINNING or current_state == STATE.GAME_OVER:
			break
			

		current_state = STATE.TURN_ENEMY
		for enemy in enemies.duplicate():
			if not is_instance_valid(enemy):
				continue

			enemy.action(current_weather)
			await enemy.end_turn
			
		if current_state == STATE.WINNING or current_state == STATE.GAME_OVER:
			break
			

		swap_weather()
		
	end_battle()

func swap_weather() -> void:
	if fog_counter >= 3:
		current_weather = WEATHER.CLEAR
		can_attack = false
		fog_counter = 0
	else:
		current_weather = WEATHER.FOG
		can_attack = true
		fog_counter += 1

func _on_player_died() -> void:
	current_state = STATE.GAME_OVER
	if is_instance_valid(player):
		player.set_process_unhandled_input(false)

func _on_enemy_died(enemy_die: Enemy) -> void:
	enemies.erase(enemy_die)
	if enemies.is_empty():
		current_state = STATE.WINNING


func mark_entity(entity: Node, cell: Vector2i) -> void:
	if valid_move.has(cell):
		valid_move[cell] = entity
		astar.set_point_solid(cell, true)

func unmark_entity(cell: Vector2i) -> void:
	if valid_move.has(cell):
		valid_move[cell] = null
		astar.set_point_solid(cell, false)

func mark_entity_moved(entity: Node, from_cell: Vector2i, to_cell: Vector2i) -> void:
	unmark_entity(from_cell)
	mark_entity(entity, to_cell)

func get_entity_grid_pos(entity: Node2D) -> Vector2i:
	return Vector2i(
		int(round(entity.global_position.x / TILE_SIZE)),
		int(round(entity.global_position.y / TILE_SIZE))
	)

func end_battle() -> void:
	match current_state:
		STATE.WINNING:
			pass
		STATE.GAME_OVER:
			pass
			
			
			
			
