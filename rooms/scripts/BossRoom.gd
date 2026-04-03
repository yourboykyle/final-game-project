extends RoomBase 

var boss_scene = preload("res://entities/Enemies/Boss.tscn")
@onready var spawn_point = []; 

func _ready():
	room_type = Globals.RoomType.BOSS 
	spawn_point = $Spawnpoint.get_children()
	Globals.enemy_defeated.connect(_on_enemy_defeated)
	if !(Globals.boss_spawned):
		var boss = boss_scene.instantiate()
		boss.position = spawn_point[0].position
		add_child(boss)
		Globals.boss_spawned = true
		lock_doors()

func _on_enemy_defeated(enemy_position):
	print("defeated")
	for enemy in get_children():
		if enemy.is_in_group("boss") and enemy.health > 0:
			return
	
	if !Globals.room_pickups.has(room_id):
		Globals.room_pickups[room_id] = []
	
	if !Globals.rewards_spawned.has(room_id):
		create_chest(enemy_position.x, enemy_position.y)
		create_chest(enemy_position.x, enemy_position.y + 64)
		create_chest(enemy_position.x, enemy_position.y - 64)
		Globals.room_pickups[room_id].append({"type": "chest", "position": Vector2(enemy_position.x, enemy_position.y)})
		Globals.room_pickups[room_id].append({"type": "chest", "position": Vector2(enemy_position.x, enemy_position.y + 64)})
		Globals.room_pickups[room_id].append({"type": "chest", "position": Vector2(enemy_position.x, enemy_position.y- 64)})
		
		if Globals.current_floor >= 2:
			create_chest(enemy_position.x - 64, enemy_position.y)
			create_chest(enemy_position.x - 64, enemy_position.y + 64)
			create_chest(enemy_position.x - 64, enemy_position.y - 64)
			Globals.room_pickups[room_id].append({"type": "chest", "position": Vector2(enemy_position.x - 64, enemy_position.y)})
			Globals.room_pickups[room_id].append({"type": "chest", "position": Vector2(enemy_position.x - 64, enemy_position.y + 64)})
			Globals.room_pickups[room_id].append({"type": "chest", "position": Vector2(enemy_position.x - 64, enemy_position.y - 64)})
		
		if Globals.current_floor >= 3:
			create_chest(enemy_position.x - 128, enemy_position.y)
			create_chest(enemy_position.x - 128, enemy_position.y + 128)
			create_chest(enemy_position.x - 128, enemy_position.y - 128)
			Globals.room_pickups[room_id].append({"type": "chest", "position": Vector2(enemy_position.x - 256, enemy_position.y)})
			Globals.room_pickups[room_id].append({"type": "chest", "position": Vector2(enemy_position.x - 128, enemy_position.y + 128)})
			Globals.room_pickups[room_id].append({"type": "chest", "position": Vector2(enemy_position.x - 128, enemy_position.y - 128)})
		
		Globals.rewards_spawned[room_id] = true
	
	create_bubble(enemy_position.x + 128, enemy_position.y)
	Globals.room_pickups[room_id].append({"type": "bubble", "position": Vector2(enemy_position.x+128, enemy_position.y)}) 

func restore_pickups(room_id):
	if !Globals.room_pickups.has(room_id):
		return
	
	for pickup_data in Globals.room_pickups[room_id]:
		if pickup_data["type"] == "chest":
			create_chest(pickup_data["position"].x, pickup_data["position"].y)
		if pickup_data["type"] == "bubble":
			create_bubble(pickup_data["position"].x, pickup_data["position"].y)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if Globals.room_pickups.has(room_id):
				restore_pickups(room_id)
