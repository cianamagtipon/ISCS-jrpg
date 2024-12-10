extends CharacterBody2D

class_name Character

@onready var _focus = $focus
@onready var progress_bar = $ProgressBar
@onready var animation_player = $AnimationPlayer

@export var is_player_group: bool
@export var max_health: float = 7

var health_percent: float
var health: float = 7:
	set(value):
		health = value


func _ready() -> void:
	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))


func _update_progress_bar():
	progress_bar.value = (health/max_health)*100


func _play_animation():
	animation_player.stop()
	animation_player.play("hurt")


func focus():
	_focus.show()


func unfocus():
	_focus.hide()


func take_damage(value):
	health -= value
	_play_animation()
	_update_progress_bar()


func critical_damage(value):
	health -= value
	_play_animation()
	_update_progress_bar()


func heal_damage(value):
	health += value
	_update_progress_bar()


func shield():
	health = health


func run():
	queue_free()


func is_dead():
	if health <= 0:
		_play_animation()
		await animation_player.animation_finished
		queue_free()
