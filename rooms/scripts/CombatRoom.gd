extends RoomBase

var enemy_scene = preload("res://entities/Enemies/enemy.tscn") 
@onready var spawn_points = []
@onready var nav_region = $NavigationRegion2D

func _ready():
	room_type = Globals.RoomType.COMBAT 
	
	Globals.enemy_defeated.connect(_on_enemy_defeated)
	
	if has_node("Spawnpoints"):
		spawn_points = $Spawnpoints.get_children()

func bake_navigation(): 
	var nav_poly = nav_region.navigation_polygon
	nav_region.bake_navigation_polygon()
func _on_room_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		spawn_boxes()
		await get_tree().process_frame 
		bake_navigation()
		if Globals.room_enemies.has(room_id):
			restore_enemies(room_id) 
			restore_pickups(room_id)
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

func restore_pickups(room_id):
	
	if !Globals.room_pickups.has(room_id):
		return
	
	for pickup_data in Globals.room_pickups[room_id]:
		if pickup_data["type"] == "chest":
			create_chest(pickup_data["position"].x, pickup_data["position"].y)
		if pickup_data["type"] == "bubble":
			create_bubble(pickup_data["position"].x, pickup_data["position"].y)

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

func spawn_boxes():
	var room_size = Globals.ROOM_SIZE

	var box_count = randi_range(2, 4)
	var margin = 200  # distance from walls
	var min_distance_between_boxes = 100

	var spawned_positions = []

	for i in range(box_count):
		var box = Globals.BOX.instantiate()

		var position = Vector2.ZERO
		var attempts = 0

		while attempts < 10:
			var x = randf_range(margin, room_size - margin)
			var y = randf_range(margin, room_size - margin)
			position = Vector2(x, y)

			var too_close = false
			for p in spawned_positions:
				if p.distance_to(position) < min_distance_between_boxes:
					too_close = true
					break
		
			if !too_close:
				break
		
			attempts += 1
		
		spawned_positions.append(position)
		box.position = position 
		box.add_to_group("navigation")
		add_child(box)

func _on_enemy_defeated(enemy_position):
	print("defeated")
	for enemy in get_children():
		if enemy.is_in_group("enemy") and enemy.health > 0:
			return
	
	if !Globals.room_pickups.has(room_id):
		Globals.room_pickups[room_id] = []
	
	if !Globals.opened_chests.has(room_id):
		create_chest(enemy_position.x, enemy_position.y)
		Globals.room_pickups[room_id].append({"type": "chest", "position": Vector2(enemy_position.x, enemy_position.y)})
	
	create_bubble(enemy_position.x + 256, enemy_position.y)
	Globals.room_pickups[room_id].append({"type": "bubble", "position": Vector2(enemy_position.x+256, enemy_position.y)}) 
