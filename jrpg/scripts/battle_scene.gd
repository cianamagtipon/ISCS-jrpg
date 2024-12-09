extends Node2D

@export var player_group: Node
@export var enemy_group: Node
@export var next_turn_delay: float = 1.0

var cur_char: Character

var is_battling: bool = false
var game_over : bool = false


signal character_begin_turn(character)
signal character_end_turn(character)

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(0.5).timeout
	begin_next_turn()

func begin_next_turn():
	if cur_char == player_group:
		cur_char = enemy_group
	else:
		cur_char = player_group
	
	emit_signal("character_begin_turn", cur_char)

func end_current_turn():
	emit_signal("character_end_turn", cur_char)
	
	await get_tree().create_timer(next_turn_delay).timeout
	
	if !game_over:
		begin_next_turn()
