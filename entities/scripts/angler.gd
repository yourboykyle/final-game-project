extends "res://entities/scripts/Enemy.gd" 
enum State{ 
	IDLE, 
	CHASE, 
	DASH, 
	RANGED, 
	ULTIMATE,
	BITE,
	SHOOTING
} 
#BASE VARIABLES 
var cooldown = 1.0
var speed 
var state = State.CHASE
var has_hit_player = false 
var flipped = true  
#DASH VARIABLES
var dash_timer = 0
var dash_time = 2
var dash_speed = 500
var dash_direction 
var dash_cooldown = 10 
#BITE VARIABLES
var bite_cooldown = 20
var bite_timer = 5
var bite_end = 1 
var has_spawned = false 
#RANGED VARIABLES
var ranged_cooldown = 5 
var salvos_left = 3
var salvo_timer = 0 
#ULTIMATE VARIABLES
var ultimate = false 
var ultimate_duration = 20
var teeth_timer = .5
func _ready(): 
	attack_timer = 2.0
	max_health = 1000 
	speed = 100 
	super._ready() 
	use_base_movement = false
	use_base_ai = false
	type = "boss"
	state = State.CHASE 
	Globals.boss_bar.connect_boss(self)  
	health_bar.hide()
func _physics_process(delta:float):
	match state: 
		State.IDLE: 
			cooldown -= delta 
			velocity = Vector2i.ZERO 
			$Sprite2D.rotation = 0
			if cooldown <= 0: 
				state = State.CHASE
		State.CHASE: 
			chase_player() 
			dash_cooldown -= delta 
			bite_cooldown -= delta 
			ranged_cooldown -= delta
			if health <= 1000 and !ultimate: 
				print("TRIGGERED") 
				state = State.ULTIMATE
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
			if ranged_cooldown <= 0: 
				weapon.weapon_owner = self 
				state = State.RANGED
				return  
		State.DASH:
			velocity = dash_direction * dash_speed
			dash_timer -= delta
			if dash_timer <= 0: 
				state = State.IDLE
				dash_cooldown = 10 
				cooldown = 1 
		State.RANGED: 
			velocity = Vector2.ZERO 
			salvos_left = 3 
			salvo_timer = 0
			state = State.SHOOTING 
		State.SHOOTING: 
			salvo_timer -= delta
			if salvo_timer <= 0 and salvos_left > 0: 
				var shootdirection = (player.global_position - global_position).normalized()
				var offset = deg_to_rad(15)
				weapon.shoot_projectile(weapon, shootdirection.rotated(offset), weapon.projectile_speed)
				weapon.shoot_projectile(weapon, shootdirection, weapon.projectile_speed)
				weapon.shoot_projectile(weapon, shootdirection.rotated(-offset), weapon.projectile_speed) 
				salvos_left -= 1
				salvo_timer = .5 
			if salvos_left <= 0: 
				state = State.IDLE
				cooldown = 1
				ranged_cooldown = 5
		State.ULTIMATE:
			velocity = Vector2.ZERO 
			if !ultimate: 
				self.hide() 
				$CollisionShape2D.set_disabled(true) 
				ultimate = true
				fade_darkness(Color(0.05, 0.05, 0.05), 0.5) 
				Globals.player.light.visible = true
			else: 
				ultimate_duration -= delta 
				teeth_timer -= delta
				if teeth_timer <= 0:  
					get_parent().teeth_attack()
					teeth_timer = 3 
				if ultimate_duration <= 0:
					fade_darkness(Color(1, 1, 1), 0.5) 
					Globals.player.light.visible = false 
					self.show() 
					$CollisionShape2D.set_deferred("disabled", false)
					state = State.IDLE
				
			cooldown = 1
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
					dash_cooldown = 10
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
		print("get bit")
func fade_darkness(target_color: Color, duration: float):
	if not Globals.canvas_modulate:
		return
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		Globals.canvas_modulate,
		"color",
		target_color,
		duration
	) 
		
