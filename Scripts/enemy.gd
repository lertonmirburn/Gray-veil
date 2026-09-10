extends CharacterBody2D
class_name Enemy



const TILE_SIZE: float = 16.0
const tile_size: Vector2=Vector2(16,16)

@export var stats: EntityStats
@export var patrol_point: Array[Vector2i] = []
var current_patrol_index: int = 0

var player: Player
var pos_save: Vector2i
var actor: Node
var value_noise: int
var has_target: bool = false
var grid_pos: Vector2i
var last_dir: Vector2i = Vector2i.ZERO
var current_ap:int
@export var stage_mg: Stage_management

func _ready() -> void:
	var tile_coord = (global_position / tile_size).floor()
	global_position = (tile_coord * tile_size)
	grid_pos = Vector2i(tile_coord)

func initialize(stage_management: Stage_management) -> void:
	stage_mg = stage_management
	BusStage.enemy_die.connect(is_alive)
	if stage_mg:
		stage_mg.mark_entity(self, grid_pos)

func on_hear_noise(source: Node, sound_pos: Vector2i, noise: int) -> void:
	actor = source
	pos_save = sound_pos
	value_noise = noise
	has_target = true

func action(current_weather: Stage_management.WEATHER) -> void:
	print("Enemy turn")
	if current_weather ==Stage_management.WEATHER.FOG:
		await get_tree().physics_frame
	else:
		print("MOve")
		if stats:
			current_ap = stats.ap
		while current_ap >= 0:
			current_ap-=1
			await behavier_clear_sky()
		await get_tree().physics_frame
	end_turn()

func move(target_cell: Vector2i) -> void:
	var old_cell: Vector2i = grid_pos
	grid_pos = target_cell
	
	var target_pixel: Vector2 = Vector2(target_cell.x * TILE_SIZE, target_cell.y * TILE_SIZE)
	var tween: Tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "global_position", target_pixel, 0.185).set_trans(Tween.TRANS_SINE)
	await tween.finished
	
	if stage_mg:
		stage_mg.mark_entity_moved(self, old_cell, target_cell)

func random_move() -> void:
	var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	directions.shuffle()
	
	if last_dir != Vector2i.ZERO:
		var opposite_dir = -last_dir
		directions.erase(opposite_dir)
		directions.append(opposite_dir)

	var moved: bool = false
	for dir in directions:
		var check_cell: Vector2i = grid_pos + dir
		if stage_mg and stage_mg.valid_move.has(check_cell) and stage_mg.valid_move[check_cell] == null:
			last_dir = dir
			moved = true
			await move(check_cell)
			break
			
	if not moved:
		await get_tree().create_timer(0.05).timeout

func attack(target: Player) -> void:
	print(name, " tấn công Player!") 
	await get_tree().create_timer(0.2).timeout

func behavior_foggy() -> void:
	pass
func behavier_clear_sky() -> void:
	if not (stage_mg and stage_mg.astar):
		return
		
	var player_node = find_player_in_sight(3)
	if player_node != null:
		print("Has target")
		has_target = true
		pos_save = player_node.grid_pos
		await chase_or_attack_target(pos_save)
		return
		
	if has_target:
		if grid_pos == pos_save:
			has_target = false
			await random_move()
			return
		else:
			await chase_or_attack_target(pos_save)
			return
			
	await random_move()


func find_player_in_sight(range_step: int) -> Player:
	if not (stage_mg and stage_mg.player):
		return null
		
	var player_cell: Vector2i = stage_mg.player.grid_pos
	var dist_x: int = abs(grid_pos.x - player_cell.x)
	var dist_y: int = abs(grid_pos.y - player_cell.y)
	if dist_x + dist_y > range_step:
		return null
		
	stage_mg.astar.set_point_solid(grid_pos, false)
	var was_target_solid = stage_mg.astar.is_point_solid(player_cell)
	stage_mg.astar.set_point_solid(player_cell, false)

	var path = stage_mg.astar.get_id_path(grid_pos, player_cell)
	print("Enemy cell: ", grid_pos, " | Player cell: ", player_cell)
	print("Khoảng cách Manhattan: ", dist_x + dist_y, " | Tầm quét: ", range_step)
	print("Độ dài path tìm được: ", path.size(), " | Chi tiết path: ", path)
	stage_mg.astar.set_point_solid(grid_pos, true)
	if was_target_solid:
		stage_mg.astar.set_point_solid(player_cell, true)
		
	if path.size() > 1 and (path.size() - 1) <= range_step:
		return stage_mg.player
		
	return null

func chase_or_attack_target(target_cell: Vector2i) -> void:
	stage_mg.astar.set_point_solid(grid_pos, false)
	var was_solid = stage_mg.astar.is_point_solid(target_cell)
	stage_mg.astar.set_point_solid(target_cell, false)
	
	var path: Array[Vector2i] = stage_mg.astar.get_id_path(grid_pos, target_cell)
	
	stage_mg.astar.set_point_solid(grid_pos, true)
	if was_solid:
		stage_mg.astar.set_point_solid(target_cell, true)
		
	if path.size() > 1:
		var next_cell: Vector2i = path[1]
		if stage_mg.valid_move.has(next_cell):
			var entity = stage_mg.valid_move[next_cell]
			
			if entity is Player:
				await attack(entity)
			elif entity == null:
				await move(next_cell)
			else:
				await get_tree().create_timer(0.05).timeout

func on_die() -> void:
	if stage_mg:
		stage_mg.unmark_entity(grid_pos)
	end_turn()
	queue_free()

func is_alive(node: Node) -> void:
	if node == self:
		on_die()

func end_turn() -> void:
	await get_tree().physics_frame
	BusStage.enemy_finish_turn.emit(self)
	
	return
	
