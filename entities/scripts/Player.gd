extends CharacterBody2D

signal oxygen_changed(current_oxygen: float, max_oxygen: float)

var interactables
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Life variables
@export var max_oxygen := 100.0
var oxygen := max_oxygen
@onready var death_timer: Timer = $DeathTimer
var can_die = true
signal died
var death_effect = null
var is_in_death_state = false
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
@onready var dive_cd: Timer = $DiveCD
var diving : bool = false
var can_dive = true
@export var flip_speed: float = 1250
@export var flip_window: float = 1
var can_flip = false
var flip_normal = Vector2.ZERO
var flip_timer = 0.0
# Movement variables end

func _ready() -> void:
	# Set current weapon to the weapon holders first child
	self.add_to_group("player")
	
	current_weapon = weapon_holder.get_child(0)
	current_weapon.weapon_owner = self
	
	for child in weapon_holder.get_children():
		child.hide()
	
	current_weapon.show()

	oxygen = max_oxygen
	emit_signal("oxygen_changed", oxygen, max_oxygen) 
	Globals.player = self
	interactables = get_tree().get_nodes_in_group(Globals.GROUP_STRINGS[Globals.Groups.INTERACTABLE])

	InventoryManager.hotbar_slot_selected.connect(Callable(self, "_on_hotbar_slot_selected"))

func _process(delta):
	#If the player attacks, try the current weapons attack
	if Input.is_action_pressed("attack"):
		if diving:
			return
		#Try the current weapons attack
		if current_weapon != null:
			current_weapon.try_attack()

			
	#Using just_pressed here to keep only 1 use per click
	if Input.is_action_just_pressed("attack"):
		var hotbar_index = InventoryManager.hotbar_selected_index
		var hotbar_item = InventoryManager.hotbar.get_item(hotbar_index)
		# add new consumables by copying this iff statement and replacing the id.
		if not hotbar_item.is_empty() and hotbar_item.id == 1001:
			var bubble = ItemDb.get_item(1001)
			bubble.use_item(self)
		
		if current_weapon == null:
			return
			
	
	if Input.is_action_just_pressed("interact"):
		interactables = find_interactables()
		print(interactables)
		for interactable in interactables:
			#Can add a check for if its has the method but all interactables should have it
			interactable.interact()
	
	var mouse_dir_x = (get_global_mouse_position() - global_position).normalized().x
	if mouse_dir_x > 0.45:
		sprite_2d.flip_h = false
	elif mouse_dir_x < -0.45:
		sprite_2d.flip_h = true

	_update_oxygen(delta)

func _physics_process(delta):
	var input_vector = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)

	if Input.is_action_pressed("boost"):
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
		if diving:
			return
		
		#var room = Globals.dungeon_manager.current_room
		#print("Current room:")
		#print(room.room_type)
		if can_dive: # commenting out for now and room != null and room.room_type != Globals.RoomType.BOSS:
			dive()

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
		animation_player.play("RESET")
		await $AnimationPlayer.animation_finished
		animation_player.play("flip")
		flip_timer = 0.0
	
	if current_weapon:
		current_weapon.look_at(get_global_mouse_position())
		var mouse_is_left = get_global_mouse_position().x < global_position.x
		current_weapon.get_node("Sprite2D").flip_v = mouse_is_left
		
	

	move_and_slide()


func _update_oxygen(delta):
	var decay = Globals.oxygen_decay_rate * delta * speed_multiplier #decays faster while boosting
	oxygen = max(oxygen -decay, 0);
	emit_signal("oxygen_changed", oxygen, max_oxygen)
	
	# Check oxygen levels
	if !Globals.death_disabled:
		if oxygen <= 0:
			#Start death if the player can die
			death(can_die)

func change_oxygen(amount):

	oxygen = clamp(oxygen + amount, 0, max_oxygen)

	emit_signal("oxygen_changed", oxygen, max_oxygen)
	
	if is_in_death_state and oxygen > 0:
		_exit_death_state()

func take_damage(amount):
	if diving:
		return
	oxygen -= amount
	emit_signal("oxygen_changed", oxygen, max_oxygen)
	
	if !Globals.death_disabled:
		if oxygen <= 0:
				death(can_die)


func dive():
	diving = true
	animation_player.play("RESET")
	await $AnimationPlayer.animation_finished
	animation_player.play("dive")
	dive_time.start()

func death(can_die):
	#Check if they can die, if they can, set can die to false and start 5 seconds till super death
	
	if can_die:
		self.can_die = false
		print("5 SECONDS UNTIL UNCONCIOUS")
		is_in_death_state = true
		if death_effect:
			death_effect.show_effect()
		death_timer.start()

func find_interactables():
	var found_interactables = get_tree().get_nodes_in_group(
		Globals.GROUP_STRINGS[Globals.Groups.INTERACTABLE]
	)
	
	return found_interactables

func _on_dive_time_timeout() -> void:
	diving = false
	can_dive = false
	dive_cd.start()


func _on_death_timer_timeout() -> void:
	
	if oxygen > 0:
		can_die = true
		_exit_death_state()
		return
	print(InventoryManager.run_loot)
	InventoryManager.clear_run_state()
	print(InventoryManager.run_loot)
	Globals.boss_spawned = false
	died.emit()


func _exit_death_state() -> void:
	is_in_death_state = false
	can_die = true
	death_timer.stop()
	if death_effect:
		death_effect.hide_effect()


func _on_dive_cd_timeout() -> void:
	can_dive = true

func reset_sprite():
	self.rotation = 0
	self.scale = Vector2(1, 1)

func _on_hotbar_slot_selected(slot_index: int) -> void:
	var item = InventoryManager.hotbar.get_item(slot_index)

	for child in weapon_holder.get_children():
		child.hide()

	if item.is_empty():
		current_weapon = null
		return

	var item_id = item["id"]
	var weapon_index = -1

	match item_id:
		3001: weapon_index = 0
		3002: weapon_index = 1
		3003: weapon_index = 2
		#3004 is a boss weapon that isn't in item container
		3005: weapon_index = 3
		3006: weapon_index = 4
		3007: weapon_index = 5
		3008: weapon_index = 6
	
	if weapon_index >= 0 and weapon_index < weapon_holder.get_child_count():
		current_weapon = weapon_holder.get_child(weapon_index)
		current_weapon.show()
	else:
		current_weapon = null
