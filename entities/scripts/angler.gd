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
var bite_cooldown = 20
var bite_timer = 5
var bite_end = 1 
var has_spawned = false 
var flipped = true
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
			$Sprite2D.rotation = 0
			if cooldown <= 0: 
				state = State.CHASE 
				dash_cooldown = 10
		State.CHASE: 
			chase_player() 
			dash_cooldown -= delta 
			bite_cooldown -= delta 
			if bite_cooldown <= 0: 
				state = State.BITE 
				bite_timer = 5
				bite_end = 1 
				has_spawned = false
				return
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
			bite_timer -= delta
			if bite_timer > 0:
				hide()
				$CollisionShape2D.set_disabled(true) 
				velocity = Vector2.ZERO

			else:
				if not has_spawned:
					show() 
					print("showing")
					global_position = player.global_position + Vector2(0, 250)
					sprite_2d.flip_h = false
					$Sprite2D.rotation = (player.global_position - global_position).angle() + deg_to_rad(180)
					velocity = Vector2(0, -1) * speed 
					has_spawned = true
				bite_end -= delta
				if bite_end <= 0:
					state = State.IDLE 
					bite_cooldown = 20
					has_spawned = false
					velocity = Vector2i.ZERO 
					rotation = velocity.angle()
					$CollisionShape2D.set_deferred("disabled", false)
			
			
	
	if velocity.x != 0 and state != State.BITE:
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
	if body.is_in_group("player") and (state == State.DASH or state == State.BITE) and visible: 
		if state == State.BITE: 
			Globals.player.take_damage(30) 
			bite_cooldown = 10 
			$CollisionShape2D.set_deferred("disabled", false)
		else: 
			Globals.player.take_damage(10) 
			dash_cooldown = 10  
		has_hit_player = true 
		state = State.IDLE
		cooldown = 1 
		print("get bit") # Replace with function body.
