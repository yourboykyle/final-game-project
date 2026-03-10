class_name RoomBase
extends Node2D

@export var room_id : int
@export var room_type : Globals.RoomType
@export var allowed_exits : Array[Globals.RoomExit] = []

var grid_position : Vector2i

func initialize(grid_pos: Vector2i):
	var gen = Globals.dungeon_manager

	if !gen.dungeon_layout.has(grid_pos + Globals.DIR_VECTORS[Globals.Direction.NORTH]):
		$DoorNorth.queue_free()

	if !gen.dungeon_layout.has(grid_pos + Globals.DIR_VECTORS[Globals.Direction.SOUTH]):
		$DoorSouth.queue_free()

	if !gen.dungeon_layout.has(grid_pos + Globals.DIR_VECTORS[Globals.Direction.EAST]):
		$DoorEast.queue_free()

	if !gen.dungeon_layout.has(grid_pos + Globals.DIR_VECTORS[Globals.Direction.WEST]):
		$DoorWest.queue_free()
