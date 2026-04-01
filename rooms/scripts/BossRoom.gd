extends RoomBase 

var boss_scene = preload("res://entities/Enemies/Boss.tscn")
@onready var spawn_point = []; 
var max_health = 500; 
var health = 500;
func _ready():
	room_type = Globals.RoomType.COMBAT 
	spawn_point = $Spawnpoint.get_children()
	if !(Globals.boss_spawned):
		var boss = boss_scene.instantiate()
		boss.position = spawn_point[0].position
		add_child(boss)
		Globals.boss_spawned = true
		lock_doors()
		
		
