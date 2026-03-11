extends CharacterBody2D

@export var SPEED = 1000
# Weapon Varaibles Start
# Gets the players weapon holder
@onready var weapon_holder = $WeaponHolder
var current_weapon
# Weapon Variables end

func _ready() -> void:
	# Set current weapon to the weapon holders first child
	current_weapon = weapon_holder.get_child(0)

func _process(delta):
	#If the player attacks, try the current weapons attack
	if Input.is_action_pressed("attack"):
		#Try the current weapons attack
		current_weapon.try_attack()

func _physics_process(delta):
	var input_vector = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	
	velocity = input_vector.normalized() * SPEED
	move_and_slide()
