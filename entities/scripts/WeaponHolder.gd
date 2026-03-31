extends Node2D

var facing_right = true
var weapon_offset_distance = 40.0
var player

func _process(delta): 
	player = get_parent()
	if player:
		var mouse_pos = get_global_mouse_position()
		var direction = (mouse_pos - global_position).normalized()

		var direction_magnitude = (mouse_pos - global_position).length()
		if direction_magnitude > 50:
			if direction.x > 0.6:
				facing_right = true
			elif direction.x < -0.6:
				facing_right = false


		var angle = direction.angle()
		angle = clamp(angle, -PI/2, PI/2)
		position.y = 5

		if facing_right:
			position.x = weapon_offset_distance
			rotation = angle
		else:
			position.x = -weapon_offset_distance
			rotation = angle + PI
		
