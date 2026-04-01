extends RoomBase

func _ready():
	room_type = Globals.RoomType.TREASURE
	
	if !room_id_exists():
		return
	
	create_chest(1573.0, 1503.0)

#Idk if null check is unesscessary or I could get around it a better way but wtvr
func room_id_exists():
	
	if room_id == null:
		return false
	
	return true
