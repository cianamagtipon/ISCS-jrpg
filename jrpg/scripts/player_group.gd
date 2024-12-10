extends Node2D

var players: Array = []
var valid_players: Array = []
var action_queue: Array = []
var combat_actions: Array = []

var current_health: float
var is_alive: bool = false
var is_battling: bool = false

var index: int = 0
var moves: int = 0

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
		if is_instance_valid(players[index+1]):
			moves = 1
			index += 1
		elif not is_instance_valid(players[index+1]):
			if is_instance_valid(players[index+2]):
				moves = 2
				index +=2
			elif not is_instance_valid(players[index+2]):
				moves = 3
				index +=3
		switch_focus(index, index-moves)
	
	else:
		_reset_focus()
	
	show_choice(index)
	
	switch_focus(index, index-1 if index > 0 else players.size() - 1)


func show_choice(index: int) -> void:
	enemy_group._reset_focus()
	choice.show()


func clean_up_players():
	valid_players = players.filter(is_instance_valid)


func _decide_combat_action():
	var health_percent = current_health

	for i in combat_actions:
		var action = combat_actions[i]
		
		if action == "heal":
			if randf() > health_percent + 0.2:
				cast_combat_action(action)
				return
			else:
				continue
		else:
			cast_combat_action(action)
			return


func cast_combat_action(action):
	for i in action:
		if not is_instance_valid(players[i]):
			continue
		
		if combat_actions[i] == "critical":
			players[i].critical_damage(3)
		elif combat_actions[i] == "basic":
			players[i].take_damage(1)
		elif combat_actions[i] == "heal":
			players[i].heal(1)
		
		players[i].is_dead()
		await get_tree().create_timer(1).timeout
	
	combat_actions.clear()
	action_queue.clear()
	is_battling = false


func _reset_focus():	
	for i in players.size():
		var player = players[i]
		if is_instance_valid(player):
			index = i
			break
	
	for player in players:
		if is_instance_valid(player):
			player.unfocus()


func switch_focus(x,y):
	clean_up_players()
	
	if is_instance_valid(players[x]):
		players[x].focus()
	if is_instance_valid(players[y]) and valid_players.size() > 1:
		players[y].unfocus()
