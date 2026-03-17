extends Node

var dungeon_manager
var crosshair_instance
var oxygen_decay_rate := 1.0

const CROSSHAIR = preload("res://interface/Crosshair.tscn")

@export var shooting_enabled = true

var ROOM_SIZE = 96 * 16
var ROOM_CENTER = Vector2(ROOM_SIZE / 2, ROOM_SIZE / 2)

enum RoomType {
	START,
	COMBAT,
	TREASURE,
	BOSS,
	SHOP
}

enum RoomExit {
	NORTH,
	SOUTH,
	EAST,
	WEST
}

enum Direction {
	NORTH,
	SOUTH,
	EAST,
	WEST
}

const DIR_VECTORS = {
	Direction.NORTH: Vector2i(0, -1),
	Direction.SOUTH: Vector2i(0, 1),
	Direction.EAST: Vector2i(1, 0),
	Direction.WEST: Vector2i(-1, 0)
}

const ROOM_COLORS = {
	RoomType.START: Color.FUCHSIA,
	RoomType.COMBAT: Color.RED,
	RoomType.TREASURE: Color.GOLD,
	RoomType.SHOP: Color.GRAY,
	RoomType.BOSS: Color.BLUE
}  
var spawned_rooms = {} 
var room_enemies = {} 
