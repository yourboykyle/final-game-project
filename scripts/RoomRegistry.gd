class_name RoomRegistry
extends Node

var rooms = {
	Globals.RoomType.COMBAT: preload("res://rooms/CombatRoom.tscn"),
	Globals.RoomType.TREASURE: preload("res://rooms/TreasureRoom.tscn"),
	Globals.RoomType.BOSS: preload("res://rooms/BossRoom.tscn"),
	Globals.RoomType.START: preload("res://rooms/StartRoom.tscn"),
	
	# Tutorial
	Globals.RoomType.TUTORIAL_START: preload("res://rooms/tutorial/TutorialStartRoom.tscn"),
	Globals.RoomType.TUTORIAL_MOVE: preload("res://rooms/tutorial/TutorialMoveRoom.tscn"),
	Globals.RoomType.TUTORIAL_COMBAT: preload("res://rooms/tutorial/TutorialCombatRoom.tscn"),
	Globals.RoomType.TUTORIAL_END: preload("res://rooms/tutorial/TutorialEndRoom.tscn"),
	Globals.RoomType.TUTORIAL_MAP: preload("res://rooms/tutorial/TutorialMapRoom.tscn"),
	Globals.RoomType.TUTORIAL_ATTACK: preload("res://rooms/tutorial/TutorialAttackRoom.tscn"),
	Globals.RoomType.TUTORIAL_OXYGEN: preload("res://rooms/tutorial/TutorialOxygenRoom.tscn"),

}

func get_room_scene(type: Globals.RoomType):
	return rooms.get(type)
