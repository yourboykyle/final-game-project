extends Node

@export var shooting_enabled = false

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
