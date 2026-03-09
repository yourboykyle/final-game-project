extends Node

var dungeon_generator

@export var shooting_enabled = false

var room_size = 96 * 16

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
