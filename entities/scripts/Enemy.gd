extends CharacterBody2D


@onready var player = get_parent().get_node("Player")
var SPEED = 300
var health = 100 
var max_health = 100

@onready var health_bar = $HealthBar

func _ready(): 
	print("Enemy ready at:", global_position, "Parent:", get_parent().name) 
	health_bar.max_value = max_health 
	health_bar.value = health

 
func take_damage(amount):
	health-= amount
	health_bar.value = health 
	var room_id = str(get_parent().global_position)
	if Globals.room_enemies.has(room_id):
		for data in Globals.room_enemies[room_id]:
			if data["position"] == global_position:
				data["health"] = health 
				health_bar.value = health
				break  
	if health <= 0: 
		queue_free() 
func set_health(amount): 
	health = amount 
	if health <= 0: 
		queue_free() 
func update_healthBar(amount): 
	health_bar.value = amount
	if health <= 0: 
		queue_free()
#Helper Function to simulate enemy taking damage by pressing space
#func _input(event): 
		#if event.is_action_pressed("ui_accept"): 
			#take_damage(10)
