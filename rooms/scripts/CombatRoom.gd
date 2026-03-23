extends RoomBase

var enemy_scene = preload("res://entities/Enemies/enemy.tscn") 
@onready var spawn_points = []

func _ready():
	room_type = Globals.RoomType.COMBAT  
	
	if has_node("Spawnpoints"):
		spawn_points = $Spawnpoints.get_children()


func _on_room_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player": 
		if Globals.room_enemies.has(room_id):
			restore_enemies(room_id) 
		else:
			spawn_and_save_enemies(room_id) 
func spawn_and_save_enemies(room_id): 
	if spawn_points.is_empty(): 
		return 
	spawn_points.shuffle() 
	var enemy_count = randi_range(1, spawn_points.size())
	Globals.room_enemies[room_id] = [] 
	for i in range(enemy_count): 
		var enemy = enemy_scene.instantiate() 
		enemy.enemy_id = str(i) + "_" + str(randi)
		enemy.position = spawn_points[i].position 
		add_child(enemy) 
		Globals.room_enemies[room_id].append({"id": enemy.enemy_id, "position": enemy.global_position, "health": enemy.health}) 
func restore_enemies(room_id): 
	for enemy_data in Globals.room_enemies[room_id]: 
		var enemy = enemy_scene.instantiate()
		enemy.enemy_id = enemy_data["id"] 
		enemy.position = enemy_data["position"] 
		enemy.set_health(enemy_data["health"])
		add_child(enemy)
		enemy.update_healthBar(enemy_data["health"])


func _on_room_trigger_body_exited(body: Node2D) -> void:
	if body.name == "Player": 
		save_enemy_positions()
func save_enemy_positions():

	if !Globals.room_enemies.has(room_id):
		return

	for enemy in get_children():
		if enemy.is_in_group("enemy"):
			for data in Globals.room_enemies[room_id]:
				if data["id"] == enemy.enemy_id:
					data["position"] = enemy.position
					data["health"] = enemy.health
