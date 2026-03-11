extends CharacterBody2D


@onready var player = get_parent().get_node("Player")
var SPEED = 300
var health = 100 
var max_health = 100



func _physics_process(delta):
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * SPEED 
	move_and_slide()
var enemy_scene = preload("res://entities/Enemies/enemy.tscn")

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(player.global_position, player.global_position + 50)
	add_child(enemy)

@onready var health_bar = $HealthBar

func ready(): 
	health_bar.max_value = max_health 
	health_bar.value = health
 
func take_damage(amount):
	
	health-= amount
	health_bar.value = health 
	if health <= 0: 
		queue_free() 
#Helper Function to simulate enemy taking damage by pressing space
#func _input(event): 
		#if event.is_action_pressed("ui_accept"): 
			#take_damage(10)
