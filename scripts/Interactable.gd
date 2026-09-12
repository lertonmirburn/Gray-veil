extends Area2D
class_name Interactable

@export var loot: String

var player_nearby := false
var player: Player


func _ready() -> void:
	loot = generate_item_id()


func generate_item_id() -> String:
	var province := randi_range(11, 99)
	var letter := char(randi_range(65, 90)) # A-Z
	var first := randi_range(100, 999)
	var second := randi_range(10, 99)

	return "%02d%s-%03d.%02d" % [province, letter, first, second]


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_nearby = true
		player = body


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_nearby = false
		player = null


func interact() -> void:
	if not player_nearby or player == null:
		return

	player.add_item(loot)
	print("Looted: ", loot)

	queue_free()
