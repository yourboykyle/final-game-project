extends Area2D

@export var direction : Globals.Direction

var triggered := false

func _on_body_entered(body):
	if body.name == "Player" and !Globals.doors_locked :
		Globals.dungeon_manager.change_room(direction)
