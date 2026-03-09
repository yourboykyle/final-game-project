class_name RoomRegistry
extends Node

var rooms = {
	Globals.RoomType.COMBAT: preload("res://rooms/CombatRoom.tscn"),
	Globals.RoomType.TREASURE: preload("res://rooms/TreasureRoom.tscn"),
	Globals.RoomType.BOSS: preload("res://rooms/BossRoom.tscn"),
	Globals.RoomType.SHOP: preload("res://rooms/ShopRoom.tscn"),
	Globals.RoomType.START: preload("res://rooms/StartRoom.tscn")
}

func get_room_scene(type: Globals.RoomType):
	return rooms.get(type)
