extends Consumable

func _ready():
	pass

func use_item(user):
	user.change_oxygen(5)
	
	decrease_quantity()
