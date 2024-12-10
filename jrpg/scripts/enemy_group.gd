extends Node2D

var enemies: Array = []
var action_queue: Array = []
var combat_actions: Array = []
var valid_enemies: Array = []
var action_stack: Array = []

var cur_char: Character
var current_health: float
var is_alive: bool = false
var is_battling: bool = false

var index: int = 0
var moves: int = 0

signal next_player
@onready var choice = $"../CanvasLayer/choice"


func _ready() -> void:
	enemies = get_children()
	for i in enemies.size():
		enemies[i].position = Vector2(0, i*40)
	
	show_choice()


func _process(_delta: float) -> void:
	if not choice.visible:
		if Input.is_action_just_pressed("ui_up"):
			if index > 0:
				if is_instance_valid(enemies[index-1]):
					moves = 1
					index -= 1
				elif not is_instance_valid(enemies[index-1]):
					if is_instance_valid(enemies[index-2]):
						moves = 2
						index -=2
					elif not is_instance_valid(enemies[index-2]):
						moves = 3
						index -=3
				switch_focus(index, index+moves)
		
		if Input.is_action_just_pressed("ui_down"):
			if index < enemies.size() - 1:
				if is_instance_valid(enemies[index+1]):
					moves = 1
					index += 1
				elif not is_instance_valid(enemies[index+1]):
					if is_instance_valid(enemies[index+2]):
						moves = 2
						index +=2
					elif not is_instance_valid(enemies[index+2]):
						moves = 3
						index +=3
				switch_focus(index, index-moves)
		
		if Input.is_action_just_pressed("ui_accept"):
			action_queue.push_back(index)
			emit_signal("next_player")
			
	
	if action_queue.size() == enemies.size() and not is_battling:
		is_battling = true
		_action(action_stack)


func clean_up_enemies():
	valid_enemies = enemies.filter(is_instance_valid)


func _action(action_stack):
	
	for i in range(min(action_queue.size(), combat_actions.size())):
		action_stack.append({
			"target": action_queue[i],
			"action": combat_actions[i]
			})

	for action in action_stack:
		var target_index = action["target"]
		var action_type = action["action"]
		
		if not is_instance_valid(enemies[target_index]):
			continue
		
		if action_type == "critical":
			enemies[target_index].critical_damage(3)
		elif action_type == "basic":
			enemies[target_index].take_damage(1)
		elif action_type == "heal":
			enemies[target_index].heal(1)
		
		print(target_index)
		print(combat_actions)
		enemies[target_index].is_dead()
		await get_tree().create_timer(1).timeout
			
	print(action_stack)
	combat_actions.clear()
	action_queue.clear()
	action_stack.clear()
	is_battling = false
	show_choice()


func switch_focus(x,y):
	clean_up_enemies()
	
	if is_instance_valid(enemies[x]):
		enemies[x].focus()
	if is_instance_valid(enemies[y]) and valid_enemies.size() > 1:
		enemies[y].unfocus()


func show_choice():
	choice.show()


func _reset_focus():
	for i in enemies.size():
		var enemy = enemies[i]
		if is_instance_valid(enemy):
			index = i
			break
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.unfocus()


func _start_choosing():
	_reset_focus()
	for i in enemies.size():
		var enemy = enemies[i]
		if is_instance_valid(enemy):
			index = i
			break
			
	enemies[index].focus()


func _on_attack_pressed() -> void:
	combat_actions.append("basic")
	choice.hide()
	_start_choosing()


func _on_crit_dmg_pressed() -> void:
	combat_actions.append("critical")
	choice.hide()
	_start_choosing()
