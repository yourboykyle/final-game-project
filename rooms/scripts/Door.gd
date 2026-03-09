extends Area2D

@export var direction : Globals.Direction

func _on_body_entered(body):
	print("Body entered")
	if body.name == "Player":
		Globals.dungeon_generator.change_room(direction)
