extends CharacterBody2D

@export var SPEED = 1000

func _process(delta):
	pass

func _physics_process(delta):

	var input_vector = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)

	velocity = input_vector.normalized() * SPEED
	move_and_slide()
