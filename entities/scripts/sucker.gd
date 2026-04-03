extends "res://entities/scripts/Enemy.gd"
const SUCKERSUCKING = preload("uid://cpadpadua6vrw")
const SUCKER = preload("uid://dh5b3nn01aysf")
@onready var suck_timer: Timer = $SuckTimer
@onready var suck_cd: Timer = $SuckCd

enum{WANDER, SUCK} 
var state = WANDER 
var state_time = 10
var sucking = false
var can_suck = true

func _ready(): 
	super._ready() 
	use_base_ai = true 
	use_base_movement = false 
	SPEED = 150 
	agent.target_position = get_random_point()
	if weapon: 
		weapon.queue_free() 
	type = "suck"
func _physics_process(delta: float): 
	state_time -= delta
	if state == WANDER:
		var dist = global_position.distance_to(agent.target_position)	
		if dist < 10:
			switch_state()
		elif state_time <= 0:
			switch_state()
		else:
			var next_pos = agent.get_next_path_position()
			var direction = next_pos - global_position		
			if direction.length() > 5:
				velocity = direction.normalized() * SPEED
			else:
				velocity = Vector2.ZERO
			move_and_slide()
	else:
		velocity = Vector2.ZERO 
		if state_time <= 0: 
			switch_state()
	
	if sucking:
		if can_suck:
			Globals.player.take_damage(.5)
			can_suck = false
			suck_cd.start()

func get_random_point():
	var nav_map = agent.get_navigation_map()
	var layers = agent.navigation_layers
	return NavigationServer2D.map_get_random_point(nav_map, layers, true)
func switch_state(): 
	if state == SUCK: 
		state = WANDER 
		agent.target_position = get_random_point()
		state_time = 10
	else: 
		state = SUCK
		state_time = randf_range(1.0,3.0) 
		suck_oxygen()
	
	
func suck_oxygen():
	sprite_2d.texture = SUCKERSUCKING
	sucking = true
	
	suck_timer.start()


func _on_suck_timer_timeout() -> void:
	sucking = false
	sprite_2d.texture = SUCKER


func _on_suck_cd_timeout() -> void:
	can_suck = true
