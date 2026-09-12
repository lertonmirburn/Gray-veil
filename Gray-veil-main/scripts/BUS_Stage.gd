extends Node2D

signal player_died()
signal enemy_die(enemy:Enemy)
signal player_end_turn()
signal enemy_finish_turn(enemy:Enemy)
signal battle_won
signal battle_lost
var current_stage:int=0
