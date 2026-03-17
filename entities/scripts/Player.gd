extends CharacterBody2D

signal oxygen_changed(current_oxygen: float, max_oxygen: float)

# Life variables
@export var max_oxygen := 100.0
var oxygen := max_oxygen
@onready var death_timer: Timer = $DeathTimer
var can_die = true
#Life variables end

# Weapon Varaibles Start
# Gets the players weapon holder
@onready var weapon_holder = $WeaponHolder
var current_weapon
# Weapon Variables end

@onready var sprite_2d: Sprite2D = $Sprite2D
# Movement variables
@export var SPEED = 1000
var speed_multiplier = 1
@onready var dive_time: Timer = $DiveTime
var diving : bool = false
# Movement variables end

func _ready() -> void:
	# Set current weapon to the weapon holders first child
	current_weapon = weapon_holder.get_child(0)
	oxygen = max_oxygen
	emit_signal("oxygen_changed", oxygen, max_oxygen)

func _process(delta):
	#If the player attacks, try the current weapons attack
	if Input.is_action_pressed("attack"):
		#Try the current weapons attack
		current_weapon.try_attack()
	
	sprite_2d.flip_h = get_global_mouse_position().x < global_position.x
	_update_oxygen(delta)

func _physics_process(delta):
	var input_vector = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	
	if Input.is_action_pressed("boost"):
		#Multiplier for movement
		speed_multiplier = 1.5
	else:
		speed_multiplier = 1
	
	velocity = input_vector.normalized() * SPEED * speed_multiplier
	move_and_slide()
	
	
	if Input.is_action_just_pressed("dive"):
		dive()
	
	


func _update_oxygen(delta):
	var decay = Globals.oxygen_decay_rate * delta * speed_multiplier #decays faster while boosting
	oxygen = max(oxygen -decay, 0);
	emit_signal("oxygen_changed", oxygen, max_oxygen)
	
	# Check oxygen levels
	if oxygen <= 0:
		#Start death if the player can die
		death(can_die)

func change_oxygen(amount):

	oxygen = clamp(oxygen + amount, 0, max_oxygen)

	emit_signal("oxygen_changed", oxygen, max_oxygen)

func take_damage(amount):
	if diving:
		print("missed")
		return
	
	oxygen -= amount
	emit_signal("oxygen_changed", oxygen, max_oxygen)
	
	if oxygen <= 0:
		death(can_die)
	
	print("ouch")


func dive():
	diving = true
	take_damage(1)
	dive_time.start()

func death(can_die):
	#Check if they can die, if they can, set can die to false and start 10 seconds till super death
	if can_die:
		self.can_die = false
		print("10 SECONDS UNTIL UNCONCIOUS")
		death_timer.start()
	
	return

func _on_dive_time_timeout() -> void:
	
	diving = false


func _on_death_timer_timeout() -> void:
	print("died")
