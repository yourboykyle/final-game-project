extends RoomBase
var chest_scene = preload("res://interactables/Chest.tscn") 
var chest
var first_time = true

func _ready():
	room_type = Globals.RoomType.TREASURE
	
	if !room_id_exists():
		return
	
	if !Globals.opened_chests.has(room_id):
		chest = chest_scene.instantiate()
		
		
		add_child(chest)
		chest.connect("opened", _on_chest_opened)
		chest.position = Vector2(1573.0, 1503.0)

#Idk if null check is unesscessary or I could get around it a better way but wtvr
func room_id_exists():
	
	if room_id == null:
		return false
	
	return true

func _on_chest_opened():
	Globals.opened_chests.append(room_id)
	if is_instance_valid(chest):
		remove_child(chest)
		chest = null
