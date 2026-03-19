extends Node2D



func _process(delta): 
	look_at(get_global_mouse_position())
	rotation = clamp(rotation, -PI/2, PI/2)
	# sprite.flip_v = get_global_mouse_position().x < global_position.x
