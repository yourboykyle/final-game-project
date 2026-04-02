extends "res://entities/scripts/Enemy.gd" 
const EXPLODINGBOOMER = preload("uid://c36hbi5x0c474")
@onready var sprite_2d_2: Sprite2D = $Sprite2D2

var explosion_radius = 500
func _ready(): 
	super._ready() 
	sprite_2d_2.hide()
	use_base_ai = false
	use_base_movement = false 
	stop_distance = 100 
	max_health = 50 
	health_bar.max_value = max_health
	health_bar.value = max_health
	health = max_health 
	SPEED = 750 
	type = "boom" 
	if weapon: 
		weapon.queue_free()
func _physics_process(delta: float) -> void:
	agent.target_position = player.global_position
	var distance = global_position.distance_to(player.global_position)
	var next_point = agent.get_next_path_position()
	var direction = (next_point - global_position).normalized() 
	if !stopped:
		if distance <= stop_distance: 
			velocity = Vector2i.ZERO
			stopped = true
			trigger_explosion()
		else: 
			velocity = direction * SPEED
		
	move_and_slide() 
	
func trigger_explosion(): 
	sprite_2d.texture = EXPLODINGBOOMER
	sprite_2d_2.show()
	await get_tree().create_timer(1).timeout
	sprite_2d_2.hide()
	take_damage(50) 
	if global_position.distance_to(player.global_position) <= explosion_radius:
		Globals.player.take_damage(25) 
	
