extends RoomBase 

var boss_scene = preload("res://entities/Enemies/Boss.tscn")
var angler_scene = preload("res://entities/Enemies/angler.tscn")
@onready var spawn_point = [] 
@onready var base_marker = $Teeth/BASE
var markers = false 
const WEAPON = preload("res://items/Weapons/BaseGun.tscn")
var weapon 
var boss 

func _ready():
	base_marker.add_to_group("teeth")
	room_type = Globals.RoomType.BOSS 
	spawn_point = $Spawnpoint.get_children()
	Globals.enemy_defeated.connect(_on_enemy_defeated)
	if !(Globals.boss_spawned):
		if Globals.current_floor == 3: 
			boss = angler_scene.instantiate()
		else: 
			boss = boss_scene.instantiate()
		boss.position = spawn_point[0].position
		add_child(boss) 
		boss.add_to_group("boss")
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
func teeth_attack(): 
	if !markers: 
		spawn_markers() 
	var locations = get_tree().get_nodes_in_group("teeth") 
	for i in range(0, locations.size()): 
		weapon = WEAPON.instantiate()  
		add_child(weapon)
		weapon.global_position = locations[i].global_position 
		weapon.weapon_owner = boss 
		print(weapon.weapon_owner)
		weapon.shoot_projectile(weapon, Vector2(0, 1), weapon.projectile_speed)
func spawn_markers(): 
	for i in range(10): 
		var m = Marker2D.new()
		add_child(m) 
		m.add_to_group("teeth")
		m.global_position = base_marker.global_position + Vector2(300*i, 0) 
	
