class_name RoomBase
extends Node2D

@export var room_id : int
@export var room_type : DataTypes.RoomType
@export var allowed_exits : Array[DataTypes.RoomExit] = []

var grid_position : Vector2i

func initialize(pos: Vector2i):
	grid_position = pos
