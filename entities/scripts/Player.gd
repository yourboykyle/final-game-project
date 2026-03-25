extends CharacterBody2D

signal oxygen_changed(current_oxygen: float, max_oxygen: float)

var interactables

# Life variables
@export var max_oxygen := 100.0
var oxygen := max_oxygen
@onready var death_timer: Timer = $DeathTimer
var can_die = true
signal died
#Life variables end

# Weapon Varaibles Start
# Gets the players weapon holder
@onready var weapon_holder = $WeaponHolder
var current_weapon
# Weapon Variables end

@onready var sprite_2d: Sprite2D = $Sprite2D
# Movement variables
@export var SPEED = 1000
@export var ACCELERATION = 1500
@export var FRICTION = 800
var speed_multiplier = 1
@onready var dive_time: Timer = $DiveTime
var diving : bool = false
@export var flip_speed: float = 1250
@export var flip_window: float = 1
var can_flip = false
var flip_normal = Vector2.ZERO
var flip_timer = 0.0
# Movement variables end

func _ready() -> void:
	# Set current weapon to the weapon holders first child
	current_weapon = weapon_holder.get_child(0)
	current_weapon.weapon_owner = self
	oxygen = max_oxygen
	emit_signal("oxygen_changed", oxygen, max_oxygen) 
	Globals.player = self
	interactables = get_tree().get_nodes_in_group(Globals.GROUP_STRINGS[Globals.Groups.INTERACTABLE])

func _process(delta):
	#If the player attacks, try the current weapons attack
	if Input.is_action_just_pressed("attack"):
		if diving:
			return
		#Try the current weapons attack
		current_weapon.try_attack()
	
	if Input.is_action_just_pressed("interact"):
		interactables = find_interactables()
		for interactable in interactables:
			#Can add a check for if its has the method but all interactables should have it
			interactable.interact()
			
	sprite_2d.flip_h = get_global_mouse_position().x < global_position.x
	_update_oxygen(delta)

func _physics_process(delta):
	var input_vector = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)

	if Input.is_action_pressed("boost"):
		#if diving:s
			#speed_multiplier = 1
		#else:
			#speed_multiplier = 1.5
		speed_multiplier = 1.5
	else:
		speed_multiplier = 1

	var target_speed = SPEED * speed_multiplier

	if input_vector.length() > 0:
		# Accelerate toward the input direction
		velocity = velocity.move_toward(input_vector.normalized() * target_speed, ACCELERATION * delta * speed_multiplier)

	else:
		# Decelerate to a stop when no input
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	if Input.is_action_just_pressed("dive"):
		dive()
	
	if Input.is_action_just_pressed("dash"):
		pass

	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		flip_normal = collision.get_normal()
		flip_timer = flip_window
		
	if flip_timer > 0:
		flip_timer -= delta
		can_flip = true
	else:
		can_flip = false

	if Input.is_action_just_pressed("flip") and can_flip:
		velocity = flip_normal * flip_speed * speed_multiplier
		can_flip = false
		flip_timer = 0.0

	move_and_slide()


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
		return
	oxygen -= amount
	emit_signal("oxygen_changed", oxygen, max_oxygen)
	
	if oxygen <= 0:
		death(can_die)


func dive():
	diving = true
	dive_time.start()

func death(can_die):
	#Check if they can die, if they can, set can die to false and start 10 seconds till super death
	if can_die:
		self.can_die = false
		print("5 SECONDS UNTIL UNCONCIOUS")
		death_timer.start()
	
	return

func find_interactables():
	var found_interactables = get_tree().get_nodes_in_group(
		Globals.GROUP_STRINGS[Globals.Groups.INTERACTABLE]
	)
	
	return found_interactables

func _on_dive_time_timeout() -> void:
	
	diving = false


func _on_death_timer_timeout() -> void:
	InventoryManager.clear_run_state()
	died.emit()
