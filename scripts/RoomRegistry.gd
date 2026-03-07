class_name RoomRegistry
extends Node

var rooms = {
	DataTypes.RoomType.COMBAT: preload("res://rooms/CombatRoom.tscn"),
	DataTypes.RoomType.TREASURE: preload("res://rooms/TreasureRoom.tscn"),
	DataTypes.RoomType.BOSS: preload("res://rooms/BossRoom.tscn"),
	DataTypes.RoomType.SHOP: preload("res://rooms/ShopRoom.tscn"),
	DataTypes.RoomType.START: preload("res://rooms/StartRoom.tscn")
}

func get_room_scene(type: DataTypes.RoomType):
	return rooms.get(type)
