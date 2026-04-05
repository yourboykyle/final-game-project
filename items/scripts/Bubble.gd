extends Consumable

func _ready():
	pass

func use_item(user):
	play_sound_effect()
	user.change_oxygen(10)
	
	decrease_quantity()
