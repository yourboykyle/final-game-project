extends CharacterBody2D


@onready var player = Globals.player 
@onready var agent = $NavigationAgent2D 

const WEAPON = preload("res://items/Weapons/BaseGun.tscn")
var SPEED = 250
var health
@export var max_health = 100 
var enemy_id = ""
var stop_distance = 500
var stopped = false
var weapon = "" 
var attack_timer = 0.0 
var attack_cooldown = 1.0 
var attack_range = 500  
@export var use_base_movement = true
@export var use_base_ai = true
@onready var sprite_2d: Sprite2D = $Sprite2D

@onready var health_bar = $HealthBar

func _ready(): 
	agent.avoidance_enabled = false
	print("Enemy ready at:", global_position, "Parent:", get_parent().name) 
	health = max_health;
	health_bar.max_value = max_health 
	health_bar.value = health
	weapon = WEAPON.instantiate()
	add_child(weapon)
	weapon.weapon_owner = self 
	weapon.collision_mask = 1

func _physics_process(delta: float) -> void: 
	if !use_base_ai: 
		return 
	
	if player == null:
		return

	agent.target_position = player.global_position
	
	var distance = global_position.distance_to(player.global_position)
	var next_point = agent.get_next_path_position()
	var direction = (next_point - global_position).normalized() 
	if use_base_movement: 
		if !stopped: 
			if distance > stop_distance: 
				velocity = direction * SPEED
			else: 
				velocity = Vector2i.ZERO 
				if distance < stop_distance-150: 
					stopped = true
		else: 
			velocity = -direction*SPEED 
			if distance > 1000: 
				stopped = false
	attack_timer -= delta
	
	if velocity.x != 0:
		sprite_2d.flip_h = velocity.x > 0


	if attack_timer <= 0 and distance <= attack_range:
		var shootdirection = (player.global_position - global_position).normalized()
		weapon.shoot_projectile(weapon, shootdirection, weapon.projectile_speed)
		attack_timer = attack_cooldown

	move_and_slide()

 
func take_damage(amount):
	health-= amount
	health_bar.value = health 
	var room_id = get_parent().room_id
	if Globals.room_enemies.has(room_id):
		for data in Globals.room_enemies[room_id]:
			if data["id"] == enemy_id:
				data["health"] = health 
				health_bar.value = health
				break  
	if health <= 0:
		Globals.enemy_defeated.emit(position)
		if Globals.room_enemies.has(room_id):
			for i in range(Globals.room_enemies[room_id].size()):
				var data = Globals.room_enemies[room_id][i]

				if data["id"] == enemy_id:
					Globals.room_enemies[room_id].remove_at(i)
					break
		if self.is_in_group("boss"):
			get_parent().unlock_doors(get_parent().grid_position)
			print(get_parent().name)
			print("boss dead, unlocking rooms")
		queue_free() 
					
func set_health(amount): 
	health = amount 
	if health <= 0: 
		queue_free() 
func update_healthBar(amount): 
	health_bar.value = amount
	if health <= 0: 
		queue_free()
