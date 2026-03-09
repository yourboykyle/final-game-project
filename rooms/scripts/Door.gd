extends Area2D

@export var direction : Globals.Direction

func _on_body_entered(body):
	if body.name == "Player":
		get_node("/root/Main/DungeonGenerator").change_room(direction)
