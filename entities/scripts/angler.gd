extends "res://entities/scripts/Enemy.gd" 
enum State{ 
	IDLE, 
	CHASE, 
	DASH, 
	RANGED, 
	ULTIMATE,
	BITE
} 
var cooldown = 1.0
var speed 
var state = State.CHASE
var dash_timer = 0
var dash_time = 2
var dash_speed = 500
var dash_direction 
var dash_cooldown = 10 
var has_hit_player = false
func _ready(): 
	attack_timer = 2.0
	max_health = 1000 
	speed = 100 
	super._ready() 
	use_base_movement = false
	use_base_ai = false
	type = "boss"
	state = State.CHASE 
func _physics_process(delta:float):
	match state: 
		State.IDLE: 
			cooldown -= delta 
			velocity = Vector2i.ZERO
			if cooldown <= 0: 
				state = State.CHASE 
		State.CHASE: 
			chase_player() 
			dash_cooldown -= delta
			var distance = global_position.distance_to(player.global_position) 
			if distance <= 500 and dash_cooldown <= 0:
				var dir = player.global_position - global_position 
				if dir.length() == 0: 
					return
				dash_direction = dir.normalized()
				dash_timer = dash_time 
				state = State.DASH 
				return 
		State.DASH:
			velocity = dash_direction * dash_speed
			dash_timer -= delta
			if dash_timer <= 0: 
				state = State.IDLE
				dash_cooldown = 10 
				cooldown = 1 
		State.RANGED: 
			print("shooting teeth") 
		State.ULTIMATE: 
			print("ULTIMATE")
		State.BITE: 
			print("teleporting under and biting")
			
	
	if velocity.x != 0:
		sprite_2d.flip_h = velocity.x > 0
	
	move_and_slide()
			 
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


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and state == State.DASH: 
		Globals.player.take_damage(10) 
		has_hit_player = true 
		state = State.IDLE 
		dash_cooldown = 10 
		cooldown = 1 
		print("get bit") # Replace with function body.
