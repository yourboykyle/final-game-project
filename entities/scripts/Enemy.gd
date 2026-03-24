extends CharacterBody2D


@onready var player = Globals.player 
@onready var agent = $NavigationAgent2D 
const WEAPON = preload("res://items/Weapons/BaseGun.tscn")
var SPEED = 300
var health = 100 
var max_health = 100 
var enemy_id = ""
var stop_distance = 500
var stopped = false
var weapon = "" 
var attack_timer = 0.0 
var attack_cooldown = 1.0 
var attack_range = 500 

@onready var health_bar = $HealthBar

func _ready(): 
	print("Enemy ready at:", global_position, "Parent:", get_parent().name) 
	health_bar.max_value = max_health 
	health_bar.value = health 
	weapon = WEAPON.instantiate() 
	add_child(weapon)
	weapon.weapon_owner = self 
	 
func _physics_process(delta: float) -> void: 
	
	if player == null:
		return

	agent.target_position = player.global_position
	
	var distance = global_position.distance_to(player.global_position)
	var next_point = agent.get_next_path_position()
	var direction = (next_point - global_position).normalized() 
	if !stopped: 
		if distance > stop_distance: 
			velocity = direction * SPEED
		else: 
			velocity = Vector2i.ZERO 
			if distance < stop_distance-150: 
				stopped = true
	else: 
		velocity = -direction*SPEED
	attack_timer -= delta

	if attack_timer <= 0 and distance <= attack_range:
		var shootdirection = (player.global_position - global_position).normalized()
		weapon.shoot_projectile(weapon, shootdirection)
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
		if Globals.room_enemies.has(room_id):
			for i in range(Globals.room_enemies[room_id].size()):
				var data = Globals.room_enemies[room_id][i]

				if data["id"] == enemy_id:
					Globals.room_enemies[room_id].remove_at(i)
					break
		queue_free() 
					
func set_health(amount): 
	health = amount 
	if health <= 0: 
		queue_free() 
func update_healthBar(amount): 
	health_bar.value = amount
	if health <= 0: 
		queue_free()
