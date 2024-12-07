extends Node2D

var players: Array = []
var index: int = 0

@onready var choice = $"../CanvasLayer/choice"
@onready var enemy_group = get_node("..").get_node("EnemyGroup")

func _ready() -> void:
	players = get_children()
	for i in players.size():
		players[i].position = Vector2(0, i*32)
	
	choice.hide()
	show_choice(index)
	players[0].focus()


func _on_enemy_group_next_player() -> void:
	if index < players.size() - 1:
		index += 1
	
	else:
		index = 0
	
	show_choice(index)
	switch_focus(index, index-1 if index > 0 else players.size() - 1)


func show_choice(index: int) -> void:
	enemy_group._reset_focus()
	choice.show()
	choice.find_child("Attack").grab_focus()


func switch_focus(x,y):
	players[x].focus()
	players[y].unfocus()
