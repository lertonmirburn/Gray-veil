extends Node2D
class_name Stage_management

const TILE_SIZE: float = 16
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

@export var show_debug_grid: bool = true

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
	if tile_wall:
		rect = rect.merge(tile_wall.get_used_rect())
	
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
			var e_cell = get_entity_grid_pos(enemy)
			enemy.grid_pos = e_cell
			mark_entity(enemy, e_cell)

func game_start() -> void:
	can_attack = false
	current_weather = WEATHER.CLEAR

func game_loop() -> void:
	while current_state != STATE.WINNING and current_state != STATE.GAME_OVER:
		current_state = STATE.TURN_PLAYER
		#4
		player.action()
		await BusStage.player_end_turn
		if current_state == STATE.WINNING or current_state == STATE.GAME_OVER:
			print(current_state)
			break
			

		current_state = STATE.TURN_ENEMY
		
		for enemy in enemies.duplicate():
			if not is_instance_valid(enemy):
				continue
			enemy.action(current_weather)
			await BusStage.enemy_finish_turn
			
		if current_state == STATE.WINNING or current_state == STATE.GAME_OVER:
			break
			

		swap_weather()
		
	end_battle()

func swap_weather() -> void:
	if fog_counter >= 1:
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
		unmark_entity(player.grid_pos)
		player.set_process_unhandled_input(false)
		BusStage.battle_lost.emit()
		return

func _on_enemy_died(enemy_die: Enemy) -> void:
	print("Erasing :", enemy_die)
	enemies.erase(enemy_die)
	if(enemy_die):
		print(enemy_die)
	if enemies.is_empty():
		current_state = STATE.WINNING
		BusStage.battle_won.emit()


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
		int(floor(entity.global_position.x / TILE_SIZE)),
		int(floor(entity.global_position.y / TILE_SIZE))
	)

func end_battle() -> void:
	match current_state:
		STATE.WINNING:
			print("We won")
			BusStage.battle_lost.emit()
			pass
		STATE.GAME_OVER:
			BusStage.battle_lost.emit()
			pass
			
			
			
			
#func _process(_delta: float) -> void:
	#if show_debug_grid:
		#queue_redraw()
#func _draw() -> void:
	#if not show_debug_grid or not astar:
		#return
		#
	#var region: Rect2i = astar.region
	#for x in range(region.position.x, region.end.x):
		#for y in range(region.position.y, region.end.y):
			#var cell: Vector2i = Vector2i(x, y)
			#var draw_rect: Rect2 = Rect2(Vector2(cell) * TILE_SIZE, Vector2(TILE_SIZE, TILE_SIZE))
			#
			#if astar.is_point_solid(cell):
				#if valid_move.has(cell) and valid_move[cell] != null:
					## Ô ĐỎ ĐẬM: Ô sàn hợp lệ nhưng đang CÓ THỰC THỂ ĐỨNG
					#draw_rect(draw_rect, Color(1, 0, 0, 0.55), true)
				#else:
					## Ô XÁM TỐI: Tường hoặc Vực thẳm ngoài map
					#draw_rect(draw_rect, Color(0.1, 0.1, 0.1, 0.4), true)
			#else:
				## Ô XANH LÁ: Ô sàn trống đi được
				#draw_rect(draw_rect, Color(0, 1, 0, 0.25), true)
			#
			## Viền mỏng phân cách từng ô
			#draw_rect(draw_rect, Color(1, 1, 1, 0.15), false, 1.0)
