extends "res://entities/scripts/Enemy.gd" 

const proj = preload("res://items/Weapons/BossGun.tscn") 
const sword = preload("res://items/Weapons/BaseSword.tscn")

enum State {
	IDLE,
	CHASE,
	SWORD_ATTACK,
	BIG_ATTACK,
	COOLDOWN
}

var state = State.IDLE
var speed
var sword_range := 250.0
var sword_cooldown := 1.0
var big_attack_cooldown := 10.0

func _ready(): 
	attack_timer = 2.0
	max_health = 500 
	speed = 100 
	super._ready() 
	use_base_movement = false
	use_base_ai = false

func _physics_process(delta: float) -> void: 
	agent.target_position - player.global_position
	var distance = global_position.distance_to(player.global_position)
	attack_timer -= delta
	match state:
		State.IDLE:
			state = State.CHASE
		State.CHASE:
			chase_player()
			if attack_timer <= 0:
				if distance <= sword_range:
					state = State.SWORD_ATTACK
				else:
					state = State.BIG_ATTACK
		State.SWORD_ATTACK:
			velocity = Vector2.ZERO
			move_and_slide()
			do_sword_attack()
			attack_timer = sword_cooldown
			state = State.COOLDOWN
		State.BIG_ATTACK:
			velocity = Vector2.ZERO
			move_and_slide()
			do_big_attack()
			attack_timer = big_attack_cooldown
			state = State.COOLDOWN
		State.COOLDOWN:
			chase_player()
			if attack_timer <= 0:
				state = State.CHASE
#movement
func chase_player():
	var direction
	var next_point = agent.get_next_path_position()
#fallback incase agent is being weird
	if next_point.distance_to(global_position) > 5:
		direction = (next_point - global_position).normalized()
	else:
		direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

func do_sword_attack():
	var weapon = sword.instantiate()
	weapon.weapon_owner = self
	add_child(weapon)
	weapon.attack()
	print("sword attack")
func do_big_attack():
	var weapon = proj.instantiate()
	weapon.weapon_owner = self
	weapon.collision_mask = 1
	add_child(weapon)
	for i in range(64):
		var angle = deg_to_rad(5.625 * i)
		var dir = Vector2.RIGHT.rotated(angle)
		weapon.shoot_projectile(weapon, dir, weapon.projectile_speed)

	print("BIG attack")
