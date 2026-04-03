extends "res://entities/scripts/Enemy.gd" 

const enemy_sword = preload("res://items/Weapons/EnemySword.tscn") 
var attackfinished = true
func _ready():
	max_health = 200
	SPEED = 800
	super._ready()
	type = "melee"
	use_base_ai = false
	use_base_movement = false 
	weapon = enemy_sword.instantiate()
	add_child(weapon)
	weapon.weapon_owner = self 
	weapon.collision_mask = 1
	attack_timer = 1
func _physics_process(delta: float) -> void:
	agent.target_position = player.global_position
	var distance = global_position.distance_to(player.global_position)
	var next_point = agent.get_next_path_position()
	var direction = (next_point - global_position).normalized() 
	if (distance < 150 or !attackfinished): 
		attack_timer -= delta
		velocity = Vector2i.ZERO
		attackfinished = false 
		if attack_timer <= 0:
			weapon.attack() 
			attack_timer = 1 
			attackfinished = true
	else:
		if (attackfinished): 
			velocity = direction*SPEED  
	move_and_slide()
	
	
