extends CharacterBody2D

# Shooting stuff
const BULLET = preload("res://entities/Bullet.tscn")
@onready var crosshair = get_node("/root/Main/Crosshair")

var fire_rate = 0.15
var fire_timer = 0.0
# End shooting stuff

@export var SPEED = 1000

func _process(delta):
	# Shooting stuff
	if Globals.shooting_enabled:
		fire_timer -= delta
		
		if Input.is_action_pressed("shoot") and fire_timer <= 0:
			fire_timer = fire_rate
			shoot()

func _physics_process(delta):

	var input_vector = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)

	velocity = input_vector.normalized() * SPEED
	move_and_slide()

func shoot():

	var bullet = BULLET.instantiate()

	var dir = (crosshair.global_position - global_position).normalized()
	bullet.direction = dir

	bullet.global_position = global_position

	get_tree().current_scene.add_child(bullet)
